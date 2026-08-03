---
name: critique
description: >-
  Run the Memory of Stars critique panel — dispatches to the dedicated critics
  (critique-canon, critique-story, critique-scene, critique-prose) over a chapter, act,
  or book, and aggregates their findings for the edit skill to apply. Use when the user
  wants a full review, or names no specific critique topic. Triggers: "critique",
  "review this chapter/book", "run the panel", "full review".
---

# Critique — the panel dispatcher

The critique system is four dedicated critics, each with one lens; this skill routes and
aggregates. **Critics critique; they never rewrite** — findings are applied later by the
`edit` skill (the editor), which reads the findings files this panel produces.

| Skill | Lens | Feeds edit pass |
|-------|------|-----------------|
| `critique-canon` | canon, continuity, Seven Laws, the undefined, naming | 2 (canon) |
| `critique-story` | structure, beats vs outline, Chapter-Two, ending, Writer's Test, info logistics | 1 (structure) |
| `critique-scene` | the Sarah pass — presence, choreography, emotion-in-body, conversation layer, props | 3 (scene) |
| `critique-prose` | line level — filler, adjectives/adverbs, sentence music, image gate, mechanics | 4–5 (line) |
| `critique-lexicon` | **opportunities, not defects** — where an invented word would earn its place; proposes candidates for human approval | 6 (lexicon) |

## Dispatch

- **A topic is named** ("check canon", "how's the dialogue") → invoke that one critic.
- **No topic** → run the four *defect* critics over the target (canon, story, scene,
  prose). For a chapter, run inline in sequence; for an act or whole book you MAY fan out
  one subagent per critic — confirm before spending the agents.
- **`critique-lexicon` is not part of the default panel.** It runs late, on request or as
  revision pass 6, once the prose is otherwise final — proposing coinages for sentences a
  later pass may cut is wasted review effort.

## Target & scope

A manuscript file, a chapter (by `## ` heading), an **act** (the outline's act grouping —
name the chapters it spans), a whole book folder, or a pasted excerpt. Resolve the book
slug; every critic needs its `outline.md`, `canon-ledger.md`, `synopsis.md`, `audio.yml`.

## The findings contract (all critics write this)

Each critic writes its report to the book folder:
`manuscripts/cycle-N/book-NN-slug/critiques/<topic>.md` (topic = canon | story | scene |
prose). Overwrite per run — git history keeps prior runs. Format:

```markdown
# Critique — <topic> — <target> (<scope>)
_run: <date> · standards: <guide/bible files judged against>_

**Verdict:** <one line — the axis's health in this scope>

## Findings
### F1 · <Blocker|Craft|Nit> · <chapter>
- **Where:** Chapter N — "<short anchor quote, verbatim>"
- **What:** <the defect, one sentence>
- **Why:** <the rule violated, with file/§ reference>
- **Fix:** <suggested direction — never drafted prose>

## What's working
- <2–4 specific strengths>

## Open questions
- <anything the bible/guide is silent on that this text assumes>
```

Severities: **Blocker** (canon contradiction, Laws violation, continuity error — must
fix) · **Craft** (weakens the prose/story) · **Nit** (mechanics). Ground every finding
in a rule *and* a verbatim quote; if the bible is silent, it's an open question, not an
error. Findings must be **anchored** — the quote must be findable by exact search, so
the editor can land the fix.

## Aggregate (panel mode)

After the critics finish, summarize inline for the author:

```
# Panel verdict — <target>
Canon <clean|N> · Story <sound|N> · Scene <present|N> · Prose <sings|N> · Writer's Test <n/5>
Top findings: <the 3–5 that matter most, any lens>
→ Findings written to critiques/ — run /edit to apply a pass.
```

Do not merge the findings files; the editor consumes them per-topic in pass order
(structure → canon → scene → line; see `writing-guide/revision.md`).
