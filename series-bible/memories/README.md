# Memories — the Archive's recording catalog

One file per book (`book-NN.yml`): the recordings that book yields to the Archive —
**catalog only**. The full runtime world DB (locations, characters, personas,
overrides — see `docs/_data/archive/orin-pre-pilgrimage.yml`) is built at publish;
until then these entries surface in the local-preview Archive as **sealed lights**
in orbit around their worlds, and production never sees them.

Format (mirrors the published slice shape, minus the world DB):

```yaml
book: book-NN
slices:
  - id: <slice-id>                 # kebab; becomes the world-DB file id at publish
    star: book-NN                  # the chart ref (memoriesForStar key)
    title: "..."
    frame: >                       # what this recording is, in the Archive's voice
    memories:
      - id: <kebab>
        title: "..."
        when: "..."                # in-world time phrase ("six days out · the Festival")
        chapters: [chapter-3]      # reader-gating keys: prologue, chapter-N, epilogue
        inhabit: [<persona ids>]   # planned inhabitable POVs (kebab first names)
        frame: >                   # 2–4 sentences of scene direction, slice-firewall clean
```

**The spoiler firewall applies at frame level:** a memory's frame may contain only
what that scene itself knows at that moment — nothing from later chapters, later
books, or `planning/`. Book 01 has no catalog file here — its two slices are
published and live in `docs/_data/archive/`.

**Wiring:** `scripts/gen-chart.rb` bundles these into the gitignored
`docs/_data/memories_full.json` for local preview (sealed motes, counts). At
publish, a book's slices graduate: full world DBs written into
`docs/_data/archive/`, and its catalog file here becomes the checklist.
