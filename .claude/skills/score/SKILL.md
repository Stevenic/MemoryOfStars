---
name: score
description: >-
  Produce a weighted review scorecard for a Memory of Stars book — rating it across eight
  quality categories (0-10 each) within the context of the universe's canon, with an
  overall score, a tier, and the Writer's Test gate. Use when the user wants to know how
  good a book is, rate/grade/score a novella, compare books, or track quality across the
  series. Triggers: "score this book", "review score", "how good is book N", "rate the
  book", "book scorecard", "grade the novella".
  (Named `score`, not `review`, because `/review` is the built-in PR-review command.)
---

# Score — the Memory of Stars book scorecard

Rate a book's quality **within the context of the universe's canon** and produce a
comparable, trackable score. This complements [`/critique`](../critique/SKILL.md): critique
gives detailed prose findings; **score gives numbers** so books can be compared and quality
tracked across all 30.

## 1. Resolve the target

A book folder (default: the one named, or the current/most-recent), e.g.
`manuscripts/cycle-1/book-01-the-first-pilgrim/`. Use its `manuscript.md`, plus its
`synopsis.md`, `canon-ledger.md`, `outline.md`, and `audio.yml`.

## 2. Load the standards (read before scoring)

Same canon + guide set the critic uses — read them so scores are grounded, not vibes:
- Canon: `series-bible/foundation.md`, `seven-laws.md`, `cosmology.md`, `timeline.md`,
  `glossary.md`, `canon-and-continuity.md`, and the `characters/` `locations/` `factions/` entries.
- Craft: `writing-guide/voice.md`, `style-guide.md`, `commandments.md`, `naming-conventions.md`.
- The book's own `canon-ledger.md` / `synopsis.md` and its **cycle README** (for its assigned
  facet and role — e.g. Cycle 1 Book 1 owns *memory as inheritance*).

For the Canon-Fidelity and Voice categories you may run [`/critique`](../critique/SKILL.md)
first and fold its findings into the scores. For a big/authoritative pass, you MAY fan out
one subagent per category (confirm first).

## 3. The scoring model

Rate each category **0–10**, then take the weighted total to **/100**. Weights sum to 100.

| # | Category | Weight | What it measures |
|---|----------|:------:|------------------|
| 1 | **Canon Fidelity** | 18 | Upholds the constitution ([foundation](../../../series-bible/foundation.md) + [seven-laws](../../../series-bible/seven-laws.md)); no Seven-Laws violations; continuity with the bible, glossary, and the book's own ledger. **Any chosen-one drift or premature answer to an *intentionally-undefined* question is a heavy penalty.** |
| 2 | **Theme & Core Question** | 15 | Meaningfully explores *"What must a civilization remember if it hopes to survive?"* and delivers **its assigned facet of memory** (e.g. inheritance). Advances the argument that *preserving memory is never morally neutral*. |
| 3 | **Story & Structure** | 14 | Pacing, escalation, causality, setups paid off, a satisfying shape. |
| 4 | **Character** | 14 | Depth, distinct voices, and **at least one permanent change** ("characters matter more than ideas"). |
| 5 | **Voice & Prose** | 14 | Line-level craft and adherence to [`voice.md`](../../../writing-guide/voice.md) (vertical rhythm, definition-by-negation, deadpan dialogue, flat uncanny, verbatim litany). |
| 6 | **Wonder & Mystery** | 10 | Earns the "Wow" ([Law 7](../../../series-bible/seven-laws.md#law-7--wonder-comes-first)); introduces/deepens mystery without over-explaining; respects the deliberately-undefined. |
| 7 | **Emotional Resonance** | 10 | Does it actually move the reader; is sentiment earned and unforced. |
| 8 | **Series Contribution** | 5 | Enriches the universe, plants durable continuity hooks, fits its cycle's concentric role, sets up what comes next. |

### 0–10 anchors (calibrate against these — do not grade-inflate)
- **9–10 Exceptional** — best-in-class; a model for the series.
- **7–8 Strong** — clearly succeeds; only minor gaps.
- **5–6 Competent** — works but unremarkable; notable gaps.
- **3–4 Weak** — significant problems; below the series standard.
- **0–2 Failing** — does not meet the bar.

### Overall → tier
Weighted total out of 100:
- **90–100 · S (Exemplary)**
- **80–89 · A (Strong)**
- **70–79 · B (Solid)**
- **60–69 · C (Serviceable — needs work)**
- **below 60 · D (Not ready)**

### The Writer's Test gate (override)
Independently mark each of the five ([seven-laws → Writer's Test](../../../series-bible/seven-laws.md#the-writers-test)):
teaches one new truth · leaves one mystery · permanently changes a character · changes
civilization even slightly · makes the universe feel larger. **If any fail, cap the verdict
at "Needs work — not yet publishable"** regardless of the numeric total, and name which failed.

## 4. Scoring discipline

- **Score within the universe, not generic fiction.** Beautiful prose that breaks a Law
  still tanks Canon Fidelity. Theme is scored on *this book's facet*, not memory in general.
- **Evidence, not vibes.** Each category score needs a one-line rationale citing a specific
  strength/weakness (quote or beat). No rationale → don't trust the number.
- **Be calibrated and consistent** so scores mean the same thing across all 30 books. A 7
  in Book 1 must equal a 7 in Book 20. Reserve 9–10 for the genuinely exceptional.
- Cross-book comparisons should hold the categories, weights, and anchors constant.

## 5. Output format

```
# Score — <Book title> (Book NN, <Cycle>) · <word count>

## Overall: <NN>/100 · Tier <S/A/B/C/D> · Writer's Test <5/5 | GATED>

| Category | Score | Wt | Pts | Rationale |
|----------|:-----:|:--:|:---:|-----------|
| Canon Fidelity        | n/10 | 18 | .. | <one line> |
| Theme & Core Question | n/10 | 15 | .. | <one line> |
| Story & Structure     | n/10 | 14 | .. | <one line> |
| Character             | n/10 | 14 | .. | <one line> |
| Voice & Prose         | n/10 | 14 | .. | <one line> |
| Wonder & Mystery      | n/10 | 10 | .. | <one line> |
| Emotional Resonance   | n/10 | 10 | .. | <one line> |
| Series Contribution   | n/10 |  5 | .. | <one line> |
| **Total**             |      |100 | **NN** | |

**Writer's Test:** ✅ teaches truth · ✅ leaves mystery · ✅ changes a character · ❌ changes civilization · ✅ larger universe

**Top strengths:** <2–3 bullets>
**Highest-leverage improvements:** <2–3 bullets, ranked>
**Verdict:** <one sentence>
```

Keep it tight — this is a rating, not a full edit. Point to `/critique` for the line-level
detail behind a low craft/canon score.

## 6. The series scoreboard (cross-book tracking)

After scoring, offer to record the result in **`manuscripts/scoreboard.md`** (create it if
missing) so quality is trackable across the series. One row per book; update the row on
re-score. Suggested columns:

```
| Book | Cycle | Overall | Canon | Theme | Story | Char | Voice | Wonder | Emotion | Series | W-Test | Tier |
```

(Use a fixed date passed in by the user or omit dates — the scoreboard is about relative
quality, not timestamps.)

## 7. Modes

- **Single book** (default) — one scorecard.
- **Compare / rank** — score several books, then a ranked table + short read on what
  separates the top from the bottom.
- **Re-score** — after a revision, re-run and show the delta per category (and update the
  scoreboard row).
