# scripts/

Tooling for the Memory of Stars repo.

## `build-reading.rb`

Generates the website's reading pages from the canonical manuscripts.

```
ruby scripts/build-reading.rb
```

- **Reads:** `manuscripts/cycle-*/book-*/manuscript.md` (split on `## ` headings) and each
  book's optional `audio.yml` (for `mood` / `pace` prosody hints).
- **Writes:** `docs/_reading/book-NN-<chapter>.md` — one page per **written** chapter.
  Placeholder chapters (no prose yet) are skipped, so a chapter appears on the site only
  once it's drafted.
- **Idempotent:** it clears and regenerates `docs/_reading/` each run.

### Workflow

The manuscript is the single source of truth. After you edit prose:

1. `ruby scripts/build-reading.rb`
2. Commit **both** the manuscript change and the regenerated `docs/_reading/` files.

(Generated pages are committed because GitHub Pages builds vanilla Jekyll with no build
step. If you'd rather not commit generated files, add a GitHub Action that runs this
script and deploys Pages — see `docs/README.md`.)

### Same source, future outputs

The parser here (chapters + scene breaks + `audio.yml` prosody) is also the natural hook
for an **ElevenLabs** audio exporter: walk the same manuscripts, emit SSML/segments using
each `audio.yml` voice, pronunciation lexicon, and per-chapter `mood`/`pace`.
