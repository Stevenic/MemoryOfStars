# Website (`docs/`)

The public site for The Memory of Stars — a [Jekyll](https://jekyllrb.com/) site that
**GitHub Pages builds automatically** (no GitHub Actions needed).

## Go live (one-time)

1. Push this repo to GitHub.
2. In the repo: **Settings → Pages**.
3. **Source:** _Deploy from a branch_.
4. **Branch:** `main`, **folder:** `/docs`. Save.
5. After a minute it's live at **https://stevenic.github.io/MemoryOfStars/**.

## Preview locally

Requires Ruby. From this `docs/` folder:

```bash
bundle install
bundle exec jekyll serve --livereload
```

Then open <http://localhost:4000/MemoryOfStars/>.

## How it's organized

| Path | What it is |
|------|-----------|
| `_config.yml` | Site settings (title, URL, collections, plugins). |
| `index.md`, `about.md`, `books.md`, `lore.md`, `news.md` | Top-level pages. |
| `_books/` | One file per novella's public page (blurb + Contents). Copy `book-01.md`. |
| `_reading/` | **Generated** chapter pages for the immersive reader. Do not edit by hand — see below. |
| `_lore/` | Worldbuilding entries. Copy `the-memory-of-stars.md`. |
| `_posts/` | News/blog posts, named `YYYY-MM-DD-title.md`. |
| `_layouts/`, `_includes/` | HTML templates. |
| `_data/nav.yml` | The navigation menu. |
| `assets/css/style.scss` | The theme (self-contained, no external fonts). |
| `assets/images/` | Site images and cover art. |

## Adding content

- **A book page:** copy `_books/book-01.md`, set `title`, `number`, `status`, `logline`,
  and `book_slug` (matching the manuscript folder slug — this links the page to its chapters).
- **A lore entry:** copy `_lore/the-memory-of-stars.md`, set `title` and `category`.
- **A news post:** add `_posts/YYYY-MM-DD-my-title.md` with a `title` in front matter.

## The reader (`_reading/`)

The immersive chapter reader is **generated from the manuscripts** — never edit
`_reading/` by hand. Prose lives once, in `manuscripts/.../manuscript.md`. To publish a
chapter you've written:

```bash
ruby scripts/build-reading.rb   # regenerates docs/_reading/
```

Each book page shows a **Start reading** button and a **Contents** list as soon as its
manuscript has drafted chapters. See [`../scripts/README.md`](../scripts/README.md).

## Custom domain (optional)

Add a `CNAME` file here containing your domain, set the DNS records GitHub documents,
then set `url`/`baseurl` in `_config.yml` accordingly (`baseurl: ""`).
