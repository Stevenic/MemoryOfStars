---
name: author
description: >-
  Orchestrate writing a whole Memory of Stars novella end-to-end — ground in the cycle's
  canon, generate & judge an outline, draft chapter-by-chapter, adversarially review, revise
  the outline and re-draft in a loop, polish, and score — pausing at defined HUMAN GATES for
  the creative and taste decisions the author must own. Use to write/compose/author a full
  book or novella. Triggers: "author book N", "write the whole novella", "compose book N",
  "run the book pipeline". (Distinct from `write`, which drafts a single chapter.)
---

# Author — the whole-book orchestrator

Write a complete novella from the cycle canon. This is the **orchestrator** above the atomic
skills (`outline`, `write`, `critique`, `score`); it chains them with review and revision
loops, and it runs the multi-agent fan-out / pipeline / loops via the **Workflow** tool.

## The one principle (everything follows from this)
**Autonomous grind, human taste-gates at the forks.** A fully-autonomous writer regresses to
the median. The machine does the tireless 90% (outline candidates, drafting, continuity,
review, revision, polish); the human does the irreplaceable 10% (creative direction at the
outline, the final taste call, and any genuine direction fork). **The machine's core
discipline: fix mechanical problems silently; escalate direction calls to the human.**

## The six human checkpoints (when the human is needed)

| # | Checkpoint | Where | Required? | What only the human decides |
|---|-----------|-------|-----------|-----------------------------|
| 1 | **Seed / brief** | before outlining | Optional (high-value) | The core creative bet — protagonist + wound, central mystery, emotional spine, specific ideas. The out-of-distribution injection. If skipped, ground from canon alone (more median). |
| 2 | **Outline approval** | after candidates judged, **before any drafting** | **Required** | The beat sheet itself. Nothing drafts until sign-off. |
| 3 | **Act-I check** | after Act I drafted + first proposed outline revision | Recommended (skippable) | Is the voice/tone/direction right before the full draft. |
| 4 | **Fork escalation** | during the review→revise loop | **On-demand** | Only genuine *direction* forks (soft climax, passive protagonist, a thread that needs restructuring). Mechanical fixes are handled silently. |
| 5 | **Final taste read** | after polish + score | **Required** | Does it have the spark. Approve or give notes. The machine cannot certify its own greatness. |
| 6 | **Publish** | after approval | **Required (mechanical)** | Authorize commit/push. Never automatic. |

Never pass a required gate without the human. When you reach one, **stop and present** what's
needed, concisely, then wait.

## The flow

### Phase 0 — Ground (load before anything)
- **Public canon:** the book's slot in the roadmap → its **facet + central question** (Tier 1); `series-bible/foundation.md`, `seven-laws.md`, `cosmology.md`, `glossary.md`, `canon-and-continuity.md`, relevant `characters/`·`locations/`·`factions/`; `writing-guide/voice.md`, `structure.md`, `style-guide.md`, `commandments.md`.
- **Private grounding (spoilers — read, never leak):** `planning/the-long-mystery.md` for this cycle's **meta-fragment** (Tier 2) and the resolved arc; `planning/tech-bible.md` for the tech; `planning/science-and-concepts.md` for seams. **Nothing from `planning/` may appear in any public file** (manuscript, public canon-ledger, site).
- **Continuity:** prior books' `manuscript.md` synopses + `canon-ledger.md` (names, timeline, motifs, hooks to echo/pay off).

### Phase 1 — Outline (→ GATE 2)
Do **not** single-pass it. Generate **N candidate outlines from different angles** (character-first, mystery-first, theme-first), each honoring the Shape Rule (`structure.md`: the length is the law; each candidate chooses and defends its own chapter grid). **Adversarially critique** each against the Writer's Test *and the reviewer checklist below*. **Judge-panel + synthesize** the strongest, grafting the best of the rest. Fold in any **Seed (Gate 1)**. → **GATE 2: present the outline for approval/steer.**

### Phase 2 — Draft Act I (→ GATE 3)
Draft **chapter-by-chapter, in order, with continuity carried forward** (never one-shot). Per chapter (via `write`): draft → self-critique (voice + canon + "did it hit the beat?") → revise once → update a running **continuity ledger**. After the first act → **GATE 3: present Act I + the first proposed outline revision.**

### Phase 3 — Review everything (the taste-proxy — bite hard)
Fan out **dimensional reviewers** (adversarially verify findings; don't trust one): canon/continuity · voice · structure & pacing · character arcs · Writer's Test · two-tier contribution (local resolution **and** meta-fragment) · word-count proportion · motif drift. Plus a **cross-chapter continuity sweep** (names, timeline, setups-without-payoffs).

### Phase 4 — Revise outline + re-draft (loop until clean)
Feed review findings **back into an outline revision**; re-draft affected chapters; draft Acts II–III against the improved outline (each chapter self-reviewed as in Phase 2). **Loop** review→revise until it comes back clean (loop-until-dry). **Escalate only forks (Gate 4); fix the rest.**

### Phase 5 — Polish + Score (→ GATE 5)
Line-edit for voice discipline (the single-line-**drop** used as emphasis only; dialogue beats attached; **emotion in the body — hunt the banned templates of voice.md §6**; repeated-reply ladders varied; motifs verbatim). Run `score` via its **blind independent-judge protocol** — must clear a tier threshold **and** pass the Writer's Test gate. If it can't after K tries, that's a **fork → escalate**. → **GATE 5: final taste read.**

### Phase 6 — Integrate (→ GATE 6)
Store to `manuscript.md`; add per-chapter `audio.yml` prosody; regenerate the reader (`ruby scripts/build-reading.rb`); return the **four canon-ledger artifacts** to the trunk; update the roadmap/scoreboard; log new glossary terms; flag new coined names for the bible. → **GATE 6: authorize commit/push.**

## The reviewer checklist (bake this in — it's what stops it shipping parables)
From what we've learned reviewing real chapters. Flag any of these:
- **Passive protagonist** — is the lead *out-thought by everyone* / getting the lesson *taught to* them rather than *discovering* it? (The Book-2 failure.)
- **Cerebral climax** — does the finale turn on reasoning with no **emotional line load-bearing in the same beat**?
- **Re-proving a prior book** — same thesis *and* same mechanism as an earlier book (esp. Book 1's "overload with contradiction").
- **Soft genre promise** — calls itself a detective/thriller but has no propulsion/clock.
- **Bad proportion** — a compressed climax or a thin setup (per-chapter targets are guides, not contracts).
- **Orphaned prologue** — POV/threads that don't reconnect for a third of the book.
- **On-the-nose theme** — the theme *recited* (chanted mottos, oracular side-characters) instead of *dramatized*.
- **Emotion said, not felt** — feelings named (*"[emotion] crossed his face"*, *"Panic rose inside her"*, labeled triplets) or narrator tic frames (*"The answer came too quickly"* family); mechanical one-word reply ladders; beat-less dialogue volleys. (The Book-1 reader complaint — the banned-template list lives in voice.md §6.)
- Plus the standard gates: Seven-Laws violations, chosen-one drift, answering an *intentionally-undefined* question, motif drift, continuity breaks.

## Guardrails
- **Never one-shot a book.** Chapter-by-chapter with continuity, always.
- **Never self-review.** Phase-3 reviewers and all scoring must be independent subagents that did **not** draft the text; when comparing drafts/revisions, use `score`'s blind A/B protocol. The drafter defends its own median choices — independence is what catches them.
- **Counter-steer toward restraint.** The machine's characteristic failure is *over*-writing: aphoristic narrator lines, foreshadow tells, rhetorical speeches, labeled emotions. When in doubt, underwrite — put the feeling in the body and let the plain line land (the prose must obey the book's own thesis).
- **Condition on the author's real prose.** Before drafting, read the author's own written chapters (this book and prior books) and match *their* register — never default to the model's house style.
- **Never auto-commit or auto-publish.** Gate 6 is the human's.
- **Never leak `planning/`** into public files. Ground from it; don't quote it.
- **Escalate forks, fix the rest** — the boundary in Gate 4 is the whole game. When unsure whether something is mechanical or a direction call, treat it as a direction call and ask.
- **Scale to the ask.** A first draft to react to → lighter review; "make it publishable" → the full adversarial pass and loop.
- The human holds the conviction; you are the forge and the honest reviewer. Present, don't decide, at every gate.
