---
name: write
description: >-
  Draft manuscript prose for a Memory of Stars book — one chapter at a time, in the series
  voice and on canon, from the book's outline. Use to write/draft the next chapter, a named
  chapter, or (as an orchestration over chapters) a whole book. Triggers: "write the next
  chapter", "draft chapter N", "write book N", "continue the manuscript", "draft this
  scene". Requires the book to be outlined first (see the `outline` skill).
---

# Write — the Memory of Stars drafter

Draft prose that reads like it belongs in this universe. **Write a chapter at a time.**
Never generate a whole book in one pass — good long-form is built chapter by chapter with
continuity carried forward, each one checked against canon and voice. This skill produces a
*draft* for the author to revise; it does not have the final word.

## Core principle

The unit of work is **one chapter** (or one scene). "Write a book" = loop this over the
outlined chapters in order, carrying continuity forward — see §7. If a book has no outline
yet, stop and run the `outline` skill first (a drafter with no beat sheet invents plot,
which corrupts canon).

## 1. Resolve the target

- **Book:** the folder named, or the current/most-recent (e.g. `manuscripts/cycle-1/book-02-the-archivist/`).
- **Chapter:** the one named, or **the next unwritten** (first `## ` section whose body is still the `_..._` placeholder), or **all remaining** (book mode).

**Never overwrite prose that already exists.** Only fill placeholder (`_..._`) chapters. To
rework written prose, that's the `revise` skill — or confirm explicitly first.

## 2. Load before writing (do not skip)

Write *from* the plan and the canon, not from imagination:
- **The beat to hit:** this chapter's entry in the book's `outline.md` (its summary + target word band).
- **Voice:** `writing-guide/voice.md` — write *in* it (vertical one-sentence rhythm, definition-by-negation, deadpan dialogue, flatly-rendered uncanny, verbatim litany). Also `style-guide.md` (mechanics, the `⸻` scene break, POV/tense).
- **Canon:** `series-bible/foundation.md`, `seven-laws.md`, `cosmology.md`, `glossary.md`, and the relevant `characters/` `locations/` `factions/` entries. Plus the book's `canon-ledger.md` (what to plant / pay off) and `synopsis.md`.
- **Continuity — read the already-written chapters of this book** (the non-placeholder `## ` sections) so names, facts, motifs, and the emotional thread carry forward exactly.
- **Tone:** this chapter's entry in `audio.yml` (`mood` / `pace`), if present.

## 3. Drafting rules

- **Hit the outlined beat** — accomplish what `outline.md` says this chapter is for, no more (don't race ahead into later chapters' material).
- **Length:** land within the chapter's target band. If the beat genuinely needs more/less, that's fine — flag the deviation rather than padding or truncating.
- **Voice is non-negotiable** — stacked one-sentence paragraphs; longer lines only for sensory sweeps; dialogue clipped and mostly untagged; the uncanny stated flatly with dread built by repetition/counting; land the chapter on a short resonant line. Run `voice.md`'s 30-second self-check on your own draft.
- **Canon is absolute** — obey the Seven Laws (no chosen-one framing; travel isn't free; AI isn't omniscient/evil-cliché; every tech reshapes culture). **Do not answer an *intentionally-undefined* question** (FTL, the gods, is Earth alive, who built the megastructures) — if the story approaches one, keep it open; if it genuinely must answer one, stop and flag it as a universe-level canon event for `canon-and-continuity.md`.
- **Motifs stay verbatim** — the farewell line, the two-finger gesture, established object-rules (e.g. the red bird), recurring phrases. Reproduce, don't paraphrase.
- **Plant and pay off** the `canon-ledger` hooks; connect to other books through *echoes, not sequels* in the opening cycle.
- **New canon:** if you must introduce a new named character/place/term, keep it consistent with `naming-conventions.md`, and list it at the end for the bible/glossary (the `canonize` skill files it).

## 4. Store it (match the established pipeline)

1. Insert the drafted prose into `manuscript.md`, replacing that chapter's `_..._` placeholder (heading stays `## Prologue|Chapter N|Epilogue — Title`; scene breaks are lone `⸻`).
2. Add/refresh this chapter's block in `audio.yml` (`mood`, `pace`, per-character voice notes) if not already present.
3. Regenerate the reader: `ruby scripts/build-reading.rb`.
4. Report **word count vs target**, and verify the reader page's scene-break count matches the `⸻` you wrote.

## 5. Self-check, then hand off

After drafting, do a quick pass: voice self-check (§ `voice.md`) + a canon/continuity scan
(names, facts, motifs, no answered-undefined). Then recommend a full **`/critique`** pass
and, when the book is complete, **`/score`**. List any new canon for **`canonize`**.

## 6. Do NOT auto-commit

Present the draft and the word count and **stop**. Committing is the author's call — offer
to commit (store → render → count → commit → push) but don't do it silently. The prose is
theirs; a draft is a proposal.

## 7. Whole-book mode (orchestration, not one generation)

Only when the book is fully outlined. Draft chapters **in order**, one at a time, each
carrying forward the continuity of the ones before it. After each chapter, run the voice
self-check before starting the next. Pause at the end of each chapter (or every few) to let
the author steer.

For a large push you MAY use the Workflow tool to pipeline chapters — but **confirm first**
(it spawns many agents and costs tokens), keep chapters sequential where later ones depend
on earlier continuity, and still route every chapter through canon + voice checks. Even
here: chapter-by-chapter with continuity, never a single monolithic draft.

## 8. If the book isn't outlined

Stop and say so. Offer to run the `outline` skill to build the beat sheet, chapter targets,
canon-ledger, and prosody plan first — then return here to draft.
