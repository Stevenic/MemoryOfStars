# Systems — the drill-down registry

One file per gazetteer system (`system-<id>.yml`), in the same data-first format as
`docs/_data/system-orin.yml` (the Auros exemplar): believable hard-SF architectures,
Kepler-computed orbits (period ≈ √(a³/M)), Earth-relative stats, palettes, and an
`art.prompt` per body.

**Read-to-reveal wiring:** these live bible-side because the site's Archive reveals a
star (and its system drill-down) only when its book has been read. When a book
publishes, its system file is copied to `docs/_data/` and its star added to
`stars-named.yml` — until then, nothing here is referenced by site data. The Auros
system (Book 1, revealed) already lives in `docs/_data/system-orin.yml`.
`scripts/gen-chart.rb` computes every star's accurate plate pin from the Bell-frame
(projection anchored to Auros's committed pin), emits the gitignored local-preview
chart (`starfield_full.json` + `systems_full.json`), and prints each pin ready to
copy into `stars-named.yml` at publish time. Routes: `../mesh-routes.yml`.

**Discipline (same as the exemplar):** astronomy only — no temporal-transmitter /
mesh data, ever (that layer is `planning/`). Story-surface color (town names, common
star names) at the level the Auros file uses is fine; institutions and mechanics are
not. Positions and star roll-names come from `../bell-frame.yml`; physical doctrine
from `../cosmology.md`.

**Naming across systems:** minor-body settler names (planets, moons, belts) repeat
freely between systems — isolation breeds convergence; every reach world has its
Kiln and its Char. Uniqueness holds *within* each file (ids and names) and at the
registry tier (worlds, stars, systems — unique galaxy-wide). Retired names from the
rename record are banned at every tier. See `writing-guide/naming-conventions.md`.
