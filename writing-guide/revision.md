# Revision — the pass system

How a Memory of Stars draft becomes a finished book. The doctrine, shared by working
editors everywhere and validated six times over on Book 1: **revise in passes, one job
per pass, largest problems first.** Line-polish before structure is work you redo — fix
the sentence, then cut the scene, and the fix died for nothing. And the drafter never
judges its own prose (see the blind gate, below).

Between passes: let the draft cool. Commit between passes so each is a readable diff.

## The passes, in order

**1. Structure & ending** — *does the book do its business?*
Draft against outline: does each chapter hit its beat; does the shape still fit
([the Shape Rule](structure.md)); does Chapter 2 detonate
([the Chapter-Two Rule](commandments.md#the-chapter-two-rule-where-the-hook-lives));
does it pass [the Writer's Test](commandments.md#the-writers-test-the-acceptance-gate)?
Tchaikovsky's warning governs the ending: if the ending renders the middle pointless,
the fix is rework, not shipping ([craft-tchaikovsky](craft-tchaikovsky.md) §3). Nothing
below this line is worth doing until this line passes.

**2. Canon & continuity** — *is it true?*
Names, facts, and timeline against the [bible](../series-bible/); motifs and litany
**verbatim**, not paraphrased; the Seven Laws obeyed; nothing
[intentionally undefined](../series-bible/seven-laws.md#things-that-are-intentionally-undefined)
answered; the book's canon-ledger hooks planted and paid. New coinages to the glossary
via `canonize`.

**3. Scene & choreography (the Sarah pass)** — *are the people present?*
Emotion in the body, never named — banned templates hunted ([voice.md](voice.md) §6);
beats attached, no volley past ~3 clipped lines without a body; gaze vectors, a look as
a full turn, gestures from each character's repertoire, never repeated in a scene; hooks
in the hands; the blocking test ([voice.md](voice.md) §3). Dialogue through the
conversation layer: cover the names, two agendas, no as-you-know, the said-instead.

**4. Line — filler & diction** — *is every word earning its place?*
The Dreyer list; adjective delete-test; adverbs traded for stronger verbs; no modifier
on absolutes ([voice.md](voice.md) Do/Avoid). Mechanical, fast, mergeable with pass 5
only once the habits are trained.

**5. Line — music** — *does it sing?*
Sentence-length variance restored (no drone of same-length sentences; the crescendo
sentence spent on earned beats); openers, structures, and senses varied; the
triple-fragment default broken into twos and fours; **read it aloud** — if you can tap a
steady beat to a paragraph, break the beat. Images through the gate: startling *and*
exactly true, and the narrator's own.

**6. The lexicon pass** — *where could this sing?*
The one pass that hunts opportunities rather than defects, and the one pass that **does
not change prose**. Run `critique-lexicon` over the near-final text: it finds the sites
where invented English would earn its place — compound-hungry description, an emotion with
no body, sensory poverty, the flatly-rendered uncanny, the wonder beat, chapter landings —
and proposes two or three candidates per site into [the Lexicon](lexicon.md)'s Proposed
table. **A human writer then approves, rewords, or kills each one.** Only approved words
are inserted, and insertion is a separate, tiny edit afterwards; re-check the music at each
insertion site, since a new word changes a sentence's rhythm. It runs *here* — after the
line work and before the gate — because proposing coinages for sentences an earlier pass
might cut wastes the reviewer's attention, and because a coinage inserted before the music
pass would be measured as if it had always been there.

**7. The blind gate (scoring)** — *prove it got better.*
The validated house protocol: **the drafter never scores its own prose.** An independent
judge (a separate model/session that did not write the text) receives unlabeled,
shuffled A/B versions plus the voice and canon guides and the chapter rubric — and does
not know which is the revision. Trust **within-run deltas**, not absolute scores
(absolute scores wobble between judge instances). A sweeping style pass is adopted only
if it *wins* the blind test — no-regression rule. (The show-don't-name pass won six of
six, average +11 points; that is why it's doctrine.)

**8. Proofread & publish** — *ship it clean.*
Spelling, punctuation, and mechanics against the [style guide](style-guide.md);
regenerate the reader (`ruby scripts/build-reading.rb`) and verify scene-break counts;
if the revision is reader-facing on a published book, freeze the prior text as a version
(`versions.yml`) so the picker offers both. Commit prose and generated pages together.

## Rules that hold across every pass

- **One job per pass.** A pass that fixes everything fixes nothing reliably.
- **Macro before micro.** Never polish a sentence you might cut.
- **Cooling-off between draft and revision** — the draft reads differently after a day
  than after a minute.
- **Diffs stay reviewable.** Commit between passes; a pass whose diff can't be read
  can't be trusted.
- **The author has the final word.** Every pass produces a proposal; prose is never
  overwritten without sign-off (the `edit` skill, or explicit confirmation).

## How the skills execute this

The **critique panel** (`/critique`, or the dedicated critics `critique-story`,
`critique-canon`, `critique-scene`, `critique-prose`) reviews a chapter, act, or book
and writes anchored findings to the book's `critiques/<topic>.md`. The **editor**
(`/edit`) then applies them as a second pass — in pass order, one pass per invocation,
dispositioning every finding in the critiques file — and sweeping style passes face the
blind gate (`/score`) before adoption.
