---
name: edit
description: >-
  The Memory of Stars editor — applies revision passes to existing prose (a chapter, an
  act, or a book), either as a named pass from writing-guide/revision.md or as a second
  pass driven by the critique panel's findings files (critiques/*.md). Surgical,
  diff-reviewable, one pass per invocation; never auto-commits. Triggers: "edit",
  "revise", "apply the critique findings", "second pass", "run the music pass".
---

# Edit — the editor

Rework prose that already exists. The `write` skill drafts; the critics judge; **this
skill changes the words** — surgically, one pass at a time, always as a proposal the
author reviews. The pass system is `writing-guide/revision.md`; this skill executes it.

## 1. Resolve target, scope, and mode

- **Target:** a book folder, or a chapter/act within one (an act = the outline's act
  grouping; name the chapters it spans).
- **Mode — one of two:**
  - **Findings mode (the second pass):** the book has `critiques/*.md` reports from the
    critique panel. Apply them. If several topics have findings, work in pass order —
    story → canon → scene → prose — and confirm scope if that means multiple invocations.
  - **Pass mode:** the author names a pass from `revision.md` (structure, canon, scene/
    Sarah, filler & diction, music, proofread) with no findings files involved. Run that
    pass's rubric directly against the text.
- **One pass per invocation.** A pass that fixes everything fixes nothing reliably.

## 2. Load before touching anything

- `writing-guide/revision.md` — the pass being run, and the cross-pass rules.
- `writing-guide/voice.md` + `style-guide.md` — every edited sentence must still pass
  the voice self-check.
- The book's `outline.md`, `canon-ledger.md`, `synopsis.md`, `audio.yml`.
- **Findings mode:** the relevant `critiques/<topic>.md` — treat findings as the work
  list; locate each by its verbatim anchor quote.
- The full chapters being edited (never edit from excerpts).

## 3. Editing rules

- **Macro before micro.** If open structural findings exist (`critiques/story.md` with
  unaddressed Blockers), refuse to run line passes on the affected chapters — say why.
  Never polish a sentence the structure pass might cut.
- **Surgical, not rewrites.** Change the minimum that fixes the finding; the author's
  sentences survive wherever they can. A pass is a set of targeted touches, not a
  regeneration — if a finding truly needs a scene rebuilt, flag it back to the author
  instead of silently redrafting.
- **Canon is absolute:** motifs and litany verbatim; nothing intentionally-undefined
  answered; no planning-layer leakage; the Seven Laws hold in every touched sentence.
- **Voice is absolute:** every touch obeys voice.md (including the Do/Avoid rules
  cluster) — an edit that fixes a finding but breaks the voice is not a fix.
- **Disposition every finding.** In findings mode, append to each finding in the
  critiques file: `- **Disposition:** applied — <what changed, one line>` or
  `- **Disposition:** skipped — <reason>` or `- **Disposition:** author-call — <the
  question>`. The critiques file becomes the record of the pass.
- **Don't fix what isn't flagged** beyond the pass's own rubric — no drive-by rewriting
  of scenes you happen to pass through.
- **Coinages are approval-gated.** Never insert an invented word that is not in the
  **Approved** table of `writing-guide/lexicon.md`, no matter how good it is or which
  findings file suggests it. `critiques/lexicon.md` holds *proposals*, not work orders:
  applying one requires the author to have promoted that word first. If a sentence wants a
  word that isn't approved yet, leave the prose plain and say so in the report. When you do
  insert an approved coinage, re-read the surrounding sentences for music — a new word
  changes the rhythm it lands in — and respect the entry's usage budget.

## 4. After the pass

1. Regenerate the reader: `ruby scripts/build-reading.rb`; verify scene-break counts.
2. Report: chapters touched, findings applied/skipped/escalated, word-count deltas vs
   targets.
3. **Style passes face the blind gate:** for sweeping voice-affecting passes (scene,
   music), recommend `/score` A/B (original vs revision, blind judge) before the change
   is considered adopted — the no-regression rule. Deltas decide; the drafter-editor
   never scores its own work.
4. **Published books get a version freeze:** if the book is live on the site, snapshot
   the prior text via `versions.yml` + `versions/` before the revision replaces the
   default reading text.

## 5. Do NOT auto-commit

Present the diff summary and stop. Offer to commit (prose + regenerated reader pages +
disposition-annotated critiques together, one pass per commit) — the author decides.
Never overwrite prose outside the resolved scope; never run a second pass in the same
invocation without being asked.
