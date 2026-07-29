---
name: outline
description: >-
  Develop a Memory of Stars book from a story-seed into a complete, write-ready plan — the
  beat sheet with per-chapter targets, the metadata card, the canon-ledger, a spoiler
  synopsis, and the prosody plan — designed from the start to pass the Writer's Test and
  obey the Seven Laws. Use to outline/plan/develop a novella before drafting. Triggers:
  "outline book N", "plan the next book", "develop this premise", "beat sheet for X".
  Produces the plan the `write` skill drafts from. This plans; it does not write prose.
---

# Outline — the Memory of Stars book developer

Turn a premise into a **plan a drafter can execute**: what happens, in what order, to what
end — on canon and in shape. This produces planning artifacts, **not manuscript prose**
(that's the `write` skill). Model on *The First Pilgrim* (Book 01) — the proven template —
but fit the structure to the story's scale, not a fixed mold.

## 1. Resolve the target & gather the seed

The book folder named, or the next planned book in a cycle
(e.g. `manuscripts/cycle-1/book-02-the-archivist/`). Gather its seed from:
- its **cycle README** row — the assigned **memory-facet**, scale, genre, central question, logline;
- `manuscripts/story-seeds.md`;
- the book's existing `README.md` premise, if any.

**If the premise is thin, ask the author 2–4 focused questions before outlining** — POV
character, the emotional core, the shape of the central mystery, how it should end.
Outlining is a creative act; do not invent the whole plot silently. Weave their answers in.

## 2. Load the standards & continuity

- **Canon:** `series-bible/foundation.md`, `seven-laws.md` (the Laws, the intentionally-undefined list, the Writer's Test), `cosmology.md`, `timeline.md`, `glossary.md`, `canon-and-continuity.md`, and relevant `characters/` `locations/` `factions/` entries.
- **Craft:** `writing-guide/commandments.md` (the Writer's Card), `writing-guide/voice.md`, `writing-guide/templates/novella-outline.md` (the canonical outline shape).
- **Continuity across the cycle:** the other books' `canon-ledger.md`/`synopsis.md` in this cycle — so this book connects through **echoes, not sequels**, and shares hooks without contradiction.

## 3. Design the plan

Build these, in order:
- **Spine:** logline · POV · the **memory-facet** this book owns and how it's dramatized · the central question · the emotional core (the wound the book is really about).
- **Chapter structure:** choose a chapter count + titles; give each chapter a **1–2 sentence beat** (what it accomplishes) and a **target word count**. Include a prologue/epilogue only if the story wants them.
- **Bake in the acceptance gate.** The plan must be built to pass the **Writer's Test**: teaches one new truth · leaves one mystery · permanently changes a character · changes civilization even slightly · ends larger than it began. Note *where* each is delivered.
- **Obey the Seven Laws.** No chosen-one arc (history from choices, not destiny); travel isn't free; AI isn't omniscient/evil-cliché; every important tech reshapes culture. Plan **at least one wonder beat** (Law 7).
- **Mystery discipline.** Plan what to open and what to resolve — and **do not plan to answer an *intentionally-undefined* question** (FTL, the gods, is Earth alive, who built the megastructures). If the arc needs to, flag it as a universe-level canon event for `canon-and-continuity.md` and confirm with the author.
- **Seed the canon-ledger's four artifacts** the book will establish: confirmed canon · cultural beliefs · open mysteries · continuity hooks (for later books to echo).
- **Prosody plan:** per-chapter `mood`/`pace`, and a pronunciation lexicon for any new coined names.

### Calibrate targets to how the series actually drafts
Learned from Book 01: its outline over-budgeted the climax (4,000) and under-budgeted the
resolution (1,500) — the opposite of how it drafted. In this voice, **full chapters land
~2,600–3,000 words; set-pieces run to ~4,000; connective chapters ~2,000.** Budget the
climax and the resolution *both* generously, and aim the novella total at **~28–34k**. Don't
set targets the prose won't hit — they only create false "under-target" noise later.

## 4. Write the plan files

Fill the book folder (copy shapes from Book 01 and `_template-book/`):
- **`outline.md`** — logline, POV, premise, characters in play, the chapter table (Act | Chapter | Title | Target words) + a beat per chapter, the structural summary, and the Writer's Test + continuity checklists.
- **`README.md`** — the metadata card (cycle, number, status → *Outlining*, scale, genre, memory-facet, central question, POV, target length, logline).
- **`canon-ledger.md`** — the four artifacts, seeded from the plan.
- **`synopsis.md`** — a spoiler-complete summary drawn from the structural summary.
- **`audio.yml`** — the prosody plan skeleton (voice, pronunciation lexicon, per-chapter mood/pace).
- **Rename the folder** to `book-NN-title-slug` once the title is set (update the cycle README + `manuscripts/README.md` rows to match).

Leave `manuscript.md` as the chapter-heading skeleton (`## Prologue|Chapter N|Epilogue —
Title` with `_..._` placeholders) so `write` can fill it chapter by chapter.

## 5. Present, refine, hand off

- **Present the beat sheet for the author's sign-off** before locking it — the chapter beats and the ending are theirs to steer; refine on their notes.
- **Do not auto-commit.** Offer to commit the plan files.
- **Hand off:** once approved, `write` drafts from this outline chapter by chapter; new coined names go to `canonize` for the glossary/bible; after drafting, `/critique` and `/score`.

## Guardrails

- **Plan, don't prose.** No manuscript text here.
- **Clarify, don't fabricate.** Ask when the premise is underspecified rather than inventing the author's story.
- **Don't overwrite an existing outline** without confirmation.
- Every plan is a proposal; the author has the final word on structure and ending.
