# The Memory of Stars

The source of truth for **The Memory of Stars** — a universe told across **30 novellas**, with a supporting series bible, writing guide, artwork, and a public website. It is also the groundwork for future books and a potential game set in the same universe.

> _Copyright © Steven Ickman. All rights reserved. See [`LICENSE`](LICENSE)._

## Read this first — the constitution

Two documents define the universe and outrank everything else. Every story, game, and
film is measured against them:

- **[series-bible/foundation.md](series-bible/foundation.md)** — what the universe _is_: vision, core question, tone, the Ten Writing Commandments.
- **[series-bible/seven-laws.md](series-bible/seven-laws.md)** — the constraints stories obey, what's deliberately left undefined, and The Writer's Test.

> **Core question:** _What must a civilization remember if it hopes to survive?_
> **Organizing metaphor:** _Civilization is a conversation across generations._

## Repository map

| Folder | What lives here |
|--------|-----------------|
| [`manuscripts/`](manuscripts/) | The 30 novellas — one folder per book (text, outline, synopsis, notes). |
| [`series-bible/`](series-bible/) | The canonical reference: cosmology, timeline, characters, locations, factions, glossary. |
| [`writing-guide/`](writing-guide/) | How the series is written — style, voice, naming conventions, and reusable templates. |
| [`art/`](art/) | Covers, maps, and concept art, plus the shared art-style guide. |
| [`game/`](game/) | Early design notes for the potential game set in this universe. |
| [`docs/`](docs/) | The public website (Jekyll → GitHub Pages). |

## The website

The site in [`docs/`](docs/) is a [Jekyll](https://jekyllrb.com/) site that GitHub Pages builds automatically — no CI configuration required.

**To publish it:** in the GitHub repo, go to **Settings → Pages**, set **Source: Deploy from a branch**, and choose **Branch: `main` / folder: `/docs`**. It will go live at `https://stevenic.github.io/MemoryOfStars/`.

See [`docs/README.md`](docs/README.md) for local preview instructions.

## Working conventions

- **The constitution is canon.** [`foundation.md`](series-bible/foundation.md) + [`seven-laws.md`](series-bible/seven-laws.md) outrank everything; the rest of the bible outranks the manuscripts. When things disagree, fix the lower one — never leave them out of sync. Full hierarchy in [`canon-and-continuity.md`](series-bible/canon-and-continuity.md).
- **One novella per folder** under `manuscripts/`, numbered `book-01` … `book-30`. Rename to `book-NN-title-slug` once a title exists.
- **New book?** Copy [`manuscripts/_template-book/`](manuscripts/_template-book/) into a new numbered folder.
