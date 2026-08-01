#!/usr/bin/env python3
"""Generate Memory-of-Stars body art with OpenAI's Images API (gpt-image-2).

The system data (docs/_data/system-*.yml) is the source of truth: each star and
planet carries its own art prompt. `ruby scripts/gen-art-manifest.rb` flattens
those into scripts/art/manifest.json; this script reads that manifest and paints
each body. Small-batch workflow: generate a few, look, tweak the prompt in the
YAML (re-run the manifest), regenerate with --force, `pick` the keeper.

Variants land in scripts/art/work/<system>/<id>/var-N.png. `pick` copies the
chosen one to the public asset docs/assets/art/<system>/<id>.png, which the
system view loads (falling back to the palette disc until it exists).

Commands
  status                 every asset's state (final / variants-pending / ready)
  next [N]               paint the next N assets that have no final (default all)
  gen <sel...>           paint specific assets: an id (enara), a system
                         (orin-system), 'all', or a manifest range (1-4)
  pick <id> <variant>    work/.../var-<variant>.png -> public final.png
  ls                     print the manifest

Common flags
  -n/--variations N   images per asset (default 3)
  --quality Q         low | medium | high | auto (default high)
  --model M           default gpt-image-2 (or $MOS_IMAGE_MODEL)
  --size WxH          override the per-asset size
  --ref PATH          extra reference image (repeatable) — pass an already-picked
                      planet to keep the set stylistically consistent
  --dry-run           print exactly what would be sent, call nothing
  --force             regenerate even if a final/variants exist
  --yes               skip the confirmation prompt

Needs $OPENAI_API_KEY (or an .env beside this script / up to repo root). Every
call's billed usage is appended to scripts/art/gen-log.jsonl. Pure stdlib.

  ~$0.24/image at high/1024 (output tokens only) — the full 9-body Auros set at
  -n 3 is roughly $6-7. Start with `gen enara -n 2` to sanity-check the look.
"""

import argparse
import base64
import glob
import json
import mimetypes
import os
import shutil
import sys
import time
import urllib.error
import urllib.request
import uuid

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
ART = os.path.join(HERE, "art")
MANIFEST = os.path.join(ART, "manifest.json")
WORK = os.path.join(ART, "work")
LOG = os.path.join(ART, "gen-log.jsonl")
API = "https://api.openai.com/v1"


def load_dotenv():
    """Load KEY=value from the nearest .env (walking up to repo root) without
    clobbering already-set env vars."""
    d = HERE
    for _ in range(6):
        p = os.path.join(d, ".env")
        if os.path.isfile(p):
            with open(p) as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith("#") or "=" not in line:
                        continue
                    if line.startswith("export "):
                        line = line[7:].strip()
                    k, v = line.split("=", 1)
                    os.environ.setdefault(
                        k.strip(), v.strip().strip('"').strip("'"))
            return p
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    return None


load_dotenv()
DEFAULT_MODEL = os.environ.get("MOS_IMAGE_MODEL", "gpt-image-2")

# gpt-image-2 bills per token (2026: text-in $5/M, image-in $8/M, image-out
# $30/M). High-tier output-token estimates calibrated from real runs; the ACTUAL
# billed usage from each response is what lands in gen-log.jsonl.
PRICE_PER_M = {"text_in": 5.0, "image_in": 8.0, "image_out": 30.0}
EST_OUT_TOKENS = {
    "1024x1024": {"low": 520, "medium": 2000, "high": 7900},
    "1536x1024": {"low": 780, "medium": 3000, "high": 11800},
    "1024x1536": {"low": 760, "medium": 2950, "high": 11700},
    "2048x1152": {"low": 1160, "medium": 4500, "high": 17700},
}


# ------------------------------------------------------------- manifest --

def load_manifest():
    if not os.path.exists(MANIFEST):
        sys.exit("no manifest — run: ruby scripts/gen-art-manifest.rb")
    with open(MANIFEST) as f:
        return json.load(f)["assets"]


def work_dir(a):
    return os.path.join(WORK, a["system"], a["id"])


def final_path(a):
    return os.path.join(ROOT, a["out"])


def variant_paths(a):
    return sorted(glob.glob(os.path.join(work_dir(a), "var-*.png")))


def state(a):
    """-> (code, detail): final | picked-needed | ready"""
    if os.path.exists(final_path(a)):
        return "final", ""
    v = variant_paths(a)
    if v:
        return "picked-needed", f"{len(v)} variants — pick one"
    return "ready", ""


def select(tokens, assets):
    """Resolve tokens (id, system, 'all', or manifest range/index) -> ordered
    unique list of assets."""
    by_id = {a["id"]: a for a in assets}
    picked, seen = [], set()

    def add(a):
        if a["id"] not in seen:
            seen.add(a["id"])
            picked.append(a)

    for t in tokens:
        if t == "all":
            for a in assets:
                add(a)
        elif t in by_id:
            add(by_id[t])
        elif any(a["system"] == t for a in assets):
            for a in assets:
                if a["system"] == t:
                    add(a)
        elif "-" in t and all(p.isdigit() for p in t.split("-", 1)):
            lo, hi = (int(p) for p in t.split("-", 1))
            for n in range(lo, hi + 1):
                if 1 <= n <= len(assets):
                    add(assets[n - 1])
        elif t.isdigit() and 1 <= int(t) <= len(assets):
            add(assets[int(t) - 1])
        else:
            sys.exit(f"no asset matches {t!r} "
                     f"(ids: {', '.join(sorted(by_id))})")
    return picked


# ------------------------------------------------------------- API calls --

def _post(url, data, content_type, timeout=900, tries=4):
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        sys.exit("OPENAI_API_KEY is not set (put it in scripts/art/.env or "
                 "the environment)")
    for attempt in range(1, tries + 1):
        req = urllib.request.Request(url, data=data, method="POST", headers={
            "Authorization": f"Bearer {key}", "Content-Type": content_type})
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return json.loads(resp.read())
        except urllib.error.HTTPError as e:
            body = e.read().decode("utf-8", "replace")
            if e.code in (429, 500, 502, 503) and attempt < tries:
                wait = 8 * attempt * attempt
                print(f"    HTTP {e.code}, retrying in {wait}s ...")
                time.sleep(wait)
                continue
            try:
                msg = json.loads(body)["error"]["message"]
            except Exception:
                msg = body[:400]
            sys.exit(f"API error {e.code}: {msg}")
        except (urllib.error.URLError, TimeoutError) as e:
            if attempt < tries:
                wait = 8 * attempt * attempt
                print(f"    network error ({e}), retrying in {wait}s ...")
                time.sleep(wait)
                continue
            raise


def _multipart(fields, files):
    boundary = uuid.uuid4().hex
    body = bytearray()
    for k, v in fields.items():
        body += (f"--{boundary}\r\nContent-Disposition: form-data; "
                 f'name="{k}"\r\n\r\n{v}\r\n').encode()
    for k, path in files:
        name = os.path.basename(path)
        ctype = mimetypes.guess_type(name)[0] or "application/octet-stream"
        body += (f"--{boundary}\r\nContent-Disposition: form-data; "
                 f'name="{k}"; filename="{name}"\r\n'
                 f"Content-Type: {ctype}\r\n\r\n").encode()
        with open(path, "rb") as f:
            body += f.read()
        body += b"\r\n"
    body += f"--{boundary}--\r\n".encode()
    return bytes(body), f"multipart/form-data; boundary={boundary}"


def api_images(prompt, refs, model, n, size, quality):
    """-> (list of png bytes, usage dict). images/edits when refs attached,
    images/generations otherwise."""
    fields = {"model": model, "prompt": prompt, "n": str(n), "size": size,
              "quality": quality, "output_format": "png"}
    if refs:
        body, ctype = _multipart(fields, [("image[]", p) for p in refs])
        out = _post(f"{API}/images/edits", body, ctype)
    else:
        body = json.dumps(fields).encode()
        out = _post(f"{API}/images/generations", body, "application/json")
    images = [base64.b64decode(d["b64_json"]) for d in out["data"]]
    return images, out.get("usage", {})


def usage_cost(usage):
    det = usage.get("input_tokens_details", {})
    text_in = det.get("text_tokens", usage.get("input_tokens", 0))
    img_in = det.get("image_tokens", 0)
    out = usage.get("output_tokens", 0)
    return (text_in * PRICE_PER_M["text_in"]
            + img_in * PRICE_PER_M["image_in"]
            + out * PRICE_PER_M["image_out"]) / 1e6


def est_cost(size, quality, n_images):
    q = "high" if quality == "auto" else quality
    tok = EST_OUT_TOKENS.get(size, EST_OUT_TOKENS["1024x1024"])[q]
    return tok * PRICE_PER_M["image_out"] / 1e6 * n_images


# --------------------------------------------------------------- actions --

MARK = {"final": "✓ final", "picked-needed": "▣ ", "ready": "▶ ready"}


def cmd_status(args):
    assets = load_manifest()
    counts = {}
    for n, a in enumerate(assets, 1):
        code, detail = state(a)
        counts[code] = counts.get(code, 0) + 1
        print(f"{n:2d} {a['system']}/{a['id']:<10} "
              f"{MARK[code]}{detail}")
    print("\n  " + " · ".join(f"{k}: {v}" for k, v in sorted(counts.items())))


def cmd_ls(args):
    for n, a in enumerate(load_manifest(), 1):
        print(f"{n:2d} {a['system']}/{a['id']:<10} {a['kind']:<7} {a['size']}")
        print(f"     {a['prompt'][:110]}"
              + ("…" if len(a["prompt"]) > 110 else ""))


def resolve_extra_refs(args):
    refs = []
    for rp in getattr(args, "ref", []) or []:
        cand = rp if os.path.exists(rp) else os.path.join(ROOT, rp)
        if not os.path.exists(cand):
            sys.exit(f"--ref image not found: {rp}")
        refs.append(cand)
    return refs


def gen_assets(assets, args):
    extra_refs = resolve_extra_refs(args)
    plan = []
    for a in assets:
        code, detail = state(a)
        if code == "final" and not args.force:
            print(f"{a['id']}: already has final.png (--force to regenerate)")
            continue
        if code == "picked-needed" and not args.force:
            print(f"{a['id']}: has variants — pick one or --force")
            continue
        plan.append(a)
    if not plan:
        print("nothing to generate")
        return

    total_imgs = len(plan) * args.variations
    total_est = sum(est_cost(args.size or a["size"], args.quality,
                             args.variations) for a in plan)
    print(f"\nplan: {len(plan)} asset(s) × {args.variations} = {total_imgs} "
          f"images | model {args.model} | quality {args.quality} | est "
          f"~${total_est:.2f} (output tokens only; actuals logged)")
    for a in plan:
        print(f"  {a['system']}/{a['id']:<10} {args.size or a['size']}"
              + (f"  +{len(extra_refs)} ref" if extra_refs else ""))

    if args.dry_run:
        print("\n--dry-run: prompts that would be sent —\n")
        for a in plan:
            print(f"───── {a['system']}/{a['id']} ─────\n{a['prompt']}\n")
        return
    if not args.yes:
        if not sys.stdin.isatty():
            sys.exit("not a tty — pass --yes to proceed")
        if input("proceed? [y/N] ").strip().lower() not in ("y", "yes"):
            sys.exit("aborted")

    for a in plan:
        wd = work_dir(a)
        os.makedirs(wd, exist_ok=True)
        if args.force:
            for old in variant_paths(a):
                os.remove(old)
        size = args.size or a["size"]
        print(f"\n{a['system']}/{a['id']}: generating {args.variations} × "
              f"{size} ...")
        t0 = time.time()
        images, usage = api_images(a["prompt"], extra_refs, args.model,
                                   args.variations, size, args.quality)
        for k, png in enumerate(images, 1):
            out = os.path.join(wd, f"var-{k}.png")
            with open(out, "wb") as f:
                f.write(png)
            print(f"    wrote {os.path.relpath(out, ROOT)}")
        cost = usage_cost(usage)
        print(f"    {time.time() - t0:.0f}s · "
              + (f"${cost:.3f} ({usage.get('total_tokens', '?')} tokens)"
                 if usage else "no usage reported"))
        with open(LOG, "a") as f:
            f.write(json.dumps(dict(
                ts=time.strftime("%Y-%m-%dT%H:%M:%S"), system=a["system"],
                id=a["id"], model=args.model, size=size,
                quality=args.quality, n=args.variations,
                refs=[os.path.relpath(r, ROOT) for r in extra_refs],
                usage=usage, cost_usd=round(cost, 4))) + "\n")
        print(f"    pick with: python3 scripts/gen-art.py pick {a['id']} "
              f"<1-{len(images)}>")


def cmd_gen(args):
    gen_assets(select(args.assets, load_manifest()), args)


def cmd_next(args):
    ready = [a for a in load_manifest() if state(a)[0] == "ready"]
    if not ready:
        print("nothing is ready — everything has a final or pending variants")
        return
    gen_assets(ready[:args.count] if args.count else ready, args)


def cmd_pick(args):
    assets = load_manifest()
    (a,) = select([args.asset], assets)
    src = os.path.join(work_dir(a), f"var-{args.variant}.png")
    if not os.path.exists(src):
        have = ", ".join(os.path.basename(v) for v in variant_paths(a)) \
            or "none"
        sys.exit(f"var-{args.variant}.png not found (have: {have})")
    dst = final_path(a)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copyfile(src, dst)
    print(f"{a['id']}: var-{args.variant}.png -> {a['out']}")


# ------------------------------------------------------------------ main --

def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    def gen_flags(p):
        p.add_argument("-n", "--variations", type=int, default=3)
        p.add_argument("--quality", default="high",
                       choices=["low", "medium", "high", "auto"])
        p.add_argument("--model", default=DEFAULT_MODEL)
        p.add_argument("--size", default=None, help="override, e.g. 1024x1024")
        p.add_argument("--ref", action="append", default=[], metavar="PATH",
                       help="extra reference image(s), repeatable")
        p.add_argument("--dry-run", action="store_true")
        p.add_argument("--force", action="store_true")
        p.add_argument("--yes", action="store_true")

    sub.add_parser("status").set_defaults(fn=cmd_status)
    sub.add_parser("ls").set_defaults(fn=cmd_ls)

    p = sub.add_parser("next")
    p.add_argument("count", nargs="?", type=int, default=0)
    gen_flags(p)
    p.set_defaults(fn=cmd_next)

    p = sub.add_parser("gen")
    p.add_argument("assets", nargs="+", help="id, system, 'all', or range 1-4")
    gen_flags(p)
    p.set_defaults(fn=cmd_gen)

    p = sub.add_parser("pick")
    p.add_argument("asset")
    p.add_argument("variant", type=int)
    p.set_defaults(fn=cmd_pick)

    args = ap.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
