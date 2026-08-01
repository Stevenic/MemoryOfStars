#!/usr/bin/env ruby
# encoding: utf-8
#
# gen-starfield.rb — generate the deterministic star catalog for the Archive map.
#
# The sky is meant to be OUR universe, plus. Real statistics, real populations, real
# placement — and, rarely, something that does not belong to nature at all.
#
#   stars       main sequence (mostly in the multiples real stars come in), white dwarfs,
#               pulsars, stellar-mass black holes, and the supermassive one at the core
#   deep        nebulae, globular + open clusters, supernova remnants, satellite galaxies
#   agn         quasars — extragalactic, redshifted, avoiding the dusty plane
#   anomalies   megastructures. Observed, never explained (Law 7 — keep them rare).
#
# On top of that sit the curated story-tied stars from docs/_data/stars-named.yml, which
# light up and become drillable once their book is read — skip the book and the star stays
# dark, a gap in the universe. Everything else is astronomy: it is there whatever you've
# read, because the sky doesn't wait for us.
#
# Deterministic (fixed seed) so it is the SAME sky every visit: a star, once a future book
# names it, keeps its place. Pure stdlib; portable (feeds web now, app later).
#
#     ruby scripts/gen-starfield.rb        # writes docs/_data/starfield.json (committed)
#
# Nothing here is named except what the books have named — generated objects carry catalog
# designations only, and their notes describe what is OBSERVED, never what it means.
#
# NO mesh / temporal-transmitter data here — that layer is private (planning/).

require 'json'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
SEED = 1985
W, H = 2000, 1200
FIELD = 700   # anonymous background stars (primaries; companions are extra)

rng = Random.new(SEED)

# Spectral-class mix — skewed a little brighter than the real stellar IMF so the field reads.
CLASS_W  = [["M", 0.58], ["K", 0.17], ["G", 0.11], ["F", 0.07], ["A", 0.045], ["B", 0.02], ["O", 0.005]]
BASE_MAG = { "O" => 0.4, "B" => 0.8, "A" => 1.6, "F" => 2.6, "G" => 3.4, "K" => 4.3, "M" => 5.3 }
SEQ      = %w[O B A F G K M]

# Multiplicity fraction by class (Raghavan+2010 for solar-type, Winters+2019 for M,
# Sana+2012 for the O/B end). Most stars are not alone; the smallest ones usually are.
MULT_FRAC = { "O" => 0.80, "B" => 0.72, "A" => 0.54, "F" => 0.46, "G" => 0.44, "K" => 0.36, "M" => 0.27 }
# Given a system IS multiple: how many stars in it. (33 : 8 : 3 binary : triple : quad+.)
MULT_N    = [[2, 0.75], [3, 0.18], [4, 0.07]]

def gauss(rng)
  u1 = [rng.rand, 1e-9].max; u2 = rng.rand
  Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2 * Math::PI * u2)
end

def weighted(rng, table)
  r = rng.rand; acc = 0.0
  table.each { |k, w| acc += w; return k if r <= acc }
  table.last[0]
end

def clampv(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v)

# ---------------------------------------------------------------- geometry --
# The galaxy runs as a band across the chart. Everything else is placed by POPULATION:
# young things hug the plane, old things sit in the halo, and the extragalactic sky hides
# from the plane entirely — the real zone of avoidance, where dust blocks the view out.
def band_y(x) = H * (0.24 + 0.52 * (x.to_f / W))
def off_band(x, y) = (y - band_y(x)).abs

def sample_pos(rng)
  cx, cy = W * 0.5, H * 0.5
  r = rng.rand
  if r < 0.42        # central bulge (elliptical gaussian)
    [cx + gauss(rng) * W * 0.14, cy + gauss(rng) * H * 0.11]
  elsif r < 0.80     # a milky band across the sky
    t = rng.rand
    [t * W, band_y(t * W) + gauss(rng) * H * 0.085]
  else               # broad halo
    [rng.rand * W, rng.rand * H]
  end
end

# Thin disk — star-forming gas, young clusters, fresh remnants. Hugs the plane.
def sample_disk(rng, spread = 0.045)
  x = rng.rand * W
  [x, band_y(x) + gauss(rng) * H * spread]
end

# Spherical halo about the core — where globular clusters actually live.
def sample_halo(rng, inner = 0.10)
  r  = inner + (1.0 - inner) * rng.rand**0.55
  th = rng.rand * 2 * Math::PI
  [W * 0.5 + Math.cos(th) * r * W * 0.47, H * 0.5 + Math.sin(th) * r * H * 0.47]
end

# Extragalactic: anything beyond our galaxy is only visible well away from the plane.
def sample_offplane(rng, min_d = H * 0.15)
  60.times do
    x, y = rng.rand * W, rng.rand * H
    return [x, y] if off_band(x, y) > min_d
  end
  [rng.rand * W, rng.rand * H * 0.12]   # fall back to the top edge, far off the plane
end

def in_bounds?(x, y) = x >= 2 && x <= W - 2 && y >= 2 && y <= H - 2

def place(rng, sampler, tries = 80, &blk)
  tries.times do
    x, y = sampler.call(rng)
    next unless in_bounds?(x, y)
    next if blk && !blk.call(x, y)
    return [x.round(1), y.round(1)]
  end
  [(W * 0.5).round(1), (H * 0.5).round(1)]
end

# ------------------------------------------------------------------ stars --
# Companion class: at or below the primary's mass. Real mass ratios are roughly flat with
# a genuine excess of near-twins, so 1-in-8 pairs come out matched.
def companion_class(rng, cls)
  i = SEQ.index(cls) || SEQ.length - 1
  return cls if rng.rand < 0.12 || i >= SEQ.length - 1
  SEQ[i + 1 + (rng.rand * (SEQ.length - i - 1)).floor]
end

# On-chart separation is SYMBOLIC: at galaxy scale every real binary is far under a pixel.
# Drawn log-uniform over a couple of chart units, so a pair reads as one fat star until you
# zoom — which is how a double actually reveals itself through a bigger telescope.
def sep_units(rng, wide = false)
  base = 0.45 * (10**rng.rand)                            # 0.45 – 4.5
  return base unless wide
  [base * (4 + rng.rand * 8), 14.0].min                   # the far member of a hierarchy,
end                                                       # kept close enough to read as one system

def companion(rng, cls, wide)
  ccls = companion_class(rng, cls)
  s    = sep_units(rng, wide)
  th   = rng.rand * 2 * Math::PI
  { 'dx' => (Math.cos(th) * s).round(2), 'dy' => (Math.sin(th) * s).round(2),
    'cls' => ccls, 'mag' => clampv(BASE_MAG[ccls] + rng.rand * 1.4, 0.0, 7.4).round(2) }
end

# Real triples and quads are HIERARCHICAL — a close pair plus a distant third (or a pair of
# pairs). Anything else is unstable and would have flung a member out long ago.
def companions(rng, cls)
  return nil if rng.rand > (MULT_FRAC[cls] || 0.3)
  n = weighted(rng, MULT_N)
  (1...n).map { |k| companion(rng, cls, k > 1) }
end

named = ((YAML.load_file(File.join(ROOT, 'docs/_data/stars-named.yml'))['stars'] rescue nil) || [])
named_pts = named.map { |s| [s['x'], s['y']] }

stars = named.map do |s|
  h = { 'id' => s['id'], 'name' => s['name'], 'x' => s['x'], 'y' => s['y'],
        'cls' => (s['cls'] || 'G'), 'mag' => (s['mag'] || 1.5), 'refs' => (s['refs'] || []) }
  h['system'] = s['system'] if s['system']
  h['note']   = s['note'] if s['note']
  h
end

clear_of_named = lambda { |x, y| named_pts.none? { |px, py| (px - x)**2 + (py - y)**2 < 1000 } }

idx = 0
tries = 0
while idx < FIELD && tries < FIELD * 40
  tries += 1
  x, y = sample_pos(rng)
  next unless in_bounds?(x, y)
  next unless clear_of_named.call(x, y)
  cls = weighted(rng, CLASS_W)
  mag = clampv(BASE_MAG[cls] + rng.rand * 1.7 - 0.4, 0.0, 7.0)
  idx += 1
  rec = { 'id' => format('MOS-%04d', 1000 + idx), 'x' => x.round(1), 'y' => y.round(1),
          'cls' => cls, 'mag' => mag.round(2) }
  comp = companions(rng, cls)
  rec['comp'] = comp if comp && !comp.empty?
  stars << rec
end

# ------------------------------------------------------- the dead and the odd --
# WHITE DWARFS — what most stars end as, and about 5% of any real neighbourhood census.
# They cool as they age, so temperature IS the colour: blue-white when young, dull orange
# after ten billion years. Old population, so they sit in a thicker, lazier disk.
wd_n = (FIELD * 0.05).round
wd_n.times do |i|
  x, y = place(rng, ->(r) { sample_pos(r) }, 40, &clear_of_named)
  t = (4000 + (rng.rand**2.1) * 24_000).round(-2)
  stars << { 'id' => format('MOS-D%03d', i + 1), 'x' => x, 'y' => y, 'kind' => 'wd',
             'cls' => 'D', 'mag' => (5.4 + rng.rand * 1.5).round(2), 't_k' => t }
end

# PULSARS — neutron stars we can only see because a beam happens to sweep us.
#   young      born in the last few hundred thousand years, still slowing; 30 ms – 1 s,
#              found in the plane where the supernovae were
#   millisecond  spun back up by a companion it stripped, now turning 100–700 times a
#              second, and almost always left orbiting the white dwarf it fed on. Globular
#              clusters are full of them — old, crowded, and good at making these pairs.
#   magnetar   the slow, violent kind: 2–12 seconds, and a magnetic field that makes it
#              flare in X-rays for decades between long silences. Only a handful are known.
PULSARS = [
  { 'sub' => 'young',       'p_ms' => 33.4 },
  { 'sub' => 'young',       'p_ms' => 89.3 },
  { 'sub' => 'young',       'p_ms' => 714.0 },
  { 'sub' => 'millisecond', 'p_ms' => 1.56 },
  { 'sub' => 'millisecond', 'p_ms' => 3.15 },
  { 'sub' => 'millisecond', 'p_ms' => 5.75 },
  { 'sub' => 'magnetar',    'p_ms' => 7_470.0 }
]
PULSARS.each_with_index do |p, i|
  sampler = p['sub'] == 'young' ? ->(r) { sample_disk(r, 0.035) } : ->(r) { sample_pos(r) }
  x, y = place(rng, sampler, 40, &clear_of_named)
  rec = { 'id' => format('MOS-P%02d', i + 1), 'x' => x, 'y' => y, 'kind' => 'pulsar',
          'sub' => p['sub'], 'p_ms' => p['p_ms'], 'mag' => 6.2 }
  # A recycled pulsar kept the star it ate from — now a white dwarf on a tight orbit.
  rec['comp'] = [{ 'dx' => (rng.rand * 2 - 1).round(2), 'dy' => (rng.rand * 2 - 1).round(2),
                   'cls' => 'D', 'mag' => 6.6 }] if p['sub'] == 'millisecond'
  stars << rec
end

# STELLAR-MASS BLACK HOLES — invisible on their own. We find them three ways, and all three
# are here: gas torn off a companion and heated until it shines in X-rays; the same, with
# jets thrown out at nearly light speed (a microquasar); and the quiet ones, betrayed only
# by a perfectly ordinary star swinging around nothing at all.
BHS = [
  { 'm_sol' => 14.8, 'mode' => 'xrb' },
  { 'm_sol' => 9.6,  'mode' => 'quiet' },
  { 'm_sol' => 21.2, 'mode' => 'microquasar' },
  { 'm_sol' => 6.9,  'mode' => 'xrb' }
]
BHS.each_with_index do |b, i|
  x, y = place(rng, ->(r) { sample_disk(r, 0.055) }, 40, &clear_of_named)
  ccls = %w[B A F G].sample(random: rng)
  stars << { 'id' => format('MOS-X%02d', i + 1), 'x' => x, 'y' => y, 'kind' => 'bh',
             'm_sol' => b['m_sol'], 'mode' => b['mode'], 'mag' => 6.8,
             'comp' => [{ 'dx' => (rng.rand < 0.5 ? -1 : 1) * (4.6 + rng.rand * 2.4).round(2),
                          'dy' => (rng.rand * 2.4 - 1.2).round(2), 'cls' => ccls,
                          'mag' => (BASE_MAG[ccls] + rng.rand).round(2) }] }
end

# THE CORE — every galaxy this size keeps a supermassive black hole at the middle of it,
# with a knot of stars whipping round on decades-long orbits. Ours is quiet: it is not
# feeding, so it shows up in radio and in the paths of the stars, not in light.
stars << { 'id' => 'MOS-CORE', 'x' => (W * 0.5).round(1), 'y' => (H * 0.5).round(1),
           'kind' => 'smbh', 'm_sol' => 4.3e6, 'mag' => 7.0, 's_stars' => 9, 'seed' => 90210 }

# ---------------------------------------------------------------- deep sky --
# Extended things, placed by the population they belong to. Clusters and shells get a seed
# instead of a member list — the renderer draws the same speckle from it every time.
deep = []
dseq = 0
add_deep = lambda do |kind, sampler, attrs|
  x, y = place(rng, sampler, 60)
  dseq += 1
  deep << { 'id' => format('MOSD-%03d', dseq), 'x' => x, 'y' => y, 'kind' => kind,
            'seed' => rng.rand(1 << 30) }.merge(attrs)
end

# Globular clusters: hundreds of thousands of ancient stars, out in the halo, older than
# the disk they orbit. Real galaxies of this size carry a hundred-odd; a chart shows a few.
8.times do
  add_deep.call('globular', ->(r) { sample_halo(r) },
                'r' => (7 + rng.rand * 8).round(1), 'n' => 90 + rng.rand(90),
                'age_gyr' => (11.0 + rng.rand * 2.2).round(1))
end
# Open clusters: young, loose, in the plane, and coming apart — they last a few hundred
# million years before the galaxy's tides pull them into the general crowd.
6.times do
  add_deep.call('open', ->(r) { sample_disk(r, 0.03) },
                'r' => (5 + rng.rand * 6).round(1), 'n' => 14 + rng.rand(26),
                'age_myr' => (30 + rng.rand * 570).round)
end
# Emission nebulae: hydrogen lit from inside by the hot stars it just made. They glow at
# 656 nm — the crimson that every real photograph of a star nursery comes out.
5.times do
  add_deep.call('emission', ->(r) { sample_disk(r, 0.025) },
                'r' => (14 + rng.rand * 22).round(1), 'ly' => (8 + rng.rand * 90).round)
end
# Reflection nebulae: dust with no light of its own, scattering a neighbour's — and blue
# for the same reason the sky is.
2.times do
  add_deep.call('reflection', ->(r) { sample_disk(r, 0.03) }, 'r' => (9 + rng.rand * 10).round(1))
end
# Dark nebulae: cold dust, visible only as a hole in the star counts behind it.
3.times do
  add_deep.call('dark', ->(r) { sample_disk(r, 0.03) }, 'r' => (16 + rng.rand * 26).round(1))
end
# Planetary nebulae: a sun-like star's shrugged-off atmosphere, lit by the white dwarf left
# in the middle. Teal, from doubly-ionised oxygen. They last ~20,000 years — nothing.
3.times do
  add_deep.call('planetary', ->(r) { sample_pos(r) },
                'r' => (3.5 + rng.rand * 3).round(1), 'age_kyr' => (3 + rng.rand * 17).round)
end
# Supernova remnants: the shell still expanding from a star that died. Thin, filamentary,
# and in the plane, because that is where the big short-lived stars are.
3.times do
  add_deep.call('snr', ->(r) { sample_disk(r, 0.03) },
                'r' => (9 + rng.rand * 12).round(1), 'age_kyr' => (1 + rng.rand * 40).round)
end
# Satellite dwarf galaxies: small companions in orbit, slowly being pulled apart.
2.times do
  add_deep.call('dwarf', ->(r) { sample_offplane(r, H * 0.20) },
                'r' => (26 + rng.rand * 26).round(1), 'kly' => (160 + rng.rand * 90).round)
end

# --------------------------------------------------------------------- agn --
# QUASARS — the cores of galaxies so far away the light left before this one had a disk.
# They look exactly like stars, which is the whole joke in the name: quasi-stellar. Faint,
# because of the distance, and never near the galactic plane — the dust in the way of the
# view out is why nobody finds them there.
#
# Lookback time from redshift, flat ΛCDM (H₀ ≈ 68, Ωm ≈ 0.31, universe 13.8 Gyr old).
LOOKBACK = [[0.0, 0.0], [0.1, 1.31], [0.25, 3.03], [0.5, 5.19], [1.0, 7.93],
            [1.5, 9.46], [2.0, 10.51], [3.0, 11.64], [4.0, 12.19], [5.0, 12.50],
            [6.0, 12.71], [7.0, 12.85]]
def lookback_gyr(z)
  LOOKBACK.each_cons(2) do |(z0, t0), (z1, t1)|
    return (t0 + (t1 - t0) * (z - z0) / (z1 - z0)).round(2) if z <= z1
  end
  LOOKBACK.last[1]
end

AGN = [
  { 'sub' => 'quasar', 'z' => 0.158, 'mag' => 12.9 },   # a bright near one, host galaxy still visible
  { 'sub' => 'quasar', 'z' => 0.53,  'mag' => 16.1 },
  { 'sub' => 'quasar', 'z' => 1.41,  'mag' => 17.8 },
  { 'sub' => 'quasar', 'z' => 2.16,  'mag' => 18.4 },
  { 'sub' => 'quasar', 'z' => 3.05,  'mag' => 19.2 },
  { 'sub' => 'quasar', 'z' => 4.72,  'mag' => 20.1 },
  { 'sub' => 'quasar', 'z' => 6.41,  'mag' => 20.8 },   # the far edge of the catalogue
  { 'sub' => 'blazar', 'z' => 0.94,  'mag' => 15.4 }    # a jet pointed straight down our throat
]
agn = AGN.each_with_index.map do |a, i|
  x, y = place(rng, ->(r) { sample_offplane(r) }, 60)
  { 'id' => format('MOSQ-%02d', i + 1), 'x' => x, 'y' => y, 'kind' => a['sub'],
    'z' => a['z'], 'mag' => a['mag'], 'gyr' => lookback_gyr(a['z']),
    'jet' => (rng.rand * 2 * Math::PI).round(3) }
end

# --------------------------------------------------------------- anomalies --
# The megastructures. Kept rare on purpose — five in a whole sky — because wonder is a
# function of scarcity (Law 7), and because the Archive is a catalogue, not an explanation.
#
# Each entry records ONLY what was observed, and how. Nothing about who, or why, or when:
# those stay on the intentionally-undefined list, and nothing in this file may answer them.
# Note that none of these are pictures — you cannot resolve an object at this distance. They
# are all inferred the way real astronomers infer things: from light going missing, and from
# heat that has nowhere to come from.
ANOMALIES = [
  { 'id' => 'MOS-A01', 'x' => 1182.0, 'y' => 688.0, 'form' => 'swarm', 'r' => 9,
    'observed' =>
      'An ordinary star, dimming in ragged steps of up to twenty-two percent. The dips do ' \
      'not repeat and no transit fits them. It runs warm in the infrared, as though a great ' \
      'deal of something cold is standing in the light.' },
  { 'id' => 'MOS-A02', 'x' => 452.0, 'y' => 286.0, 'form' => 'shell', 'r' => 11,
    'observed' =>
      'No star is visible here. The point radiates at 302 kelvin — room temperature — across ' \
      'a face two astronomical units wide, which adds up to the output of a sun. Nothing ' \
      'natural is that cold and that bright at the same time.' },
  { 'id' => 'MOS-A03', 'x' => 1642.0, 'y' => 954.0, 'form' => 'ring', 'r' => 10,
    'observed' =>
      'A dead star, eclipsed four times a year for nineteen hours at a stretch. The floor of ' \
      'the eclipse is flat. Ingress and egress take forty seconds each: whatever passes has ' \
      'an edge, and the edge is sharp.' },
  { 'id' => 'MOS-A04', 'x' => 286.0, 'y' => 968.0, 'form' => 'occulter', 'r' => 16,
    'observed' =>
      'Stars in the cluster behind it go out one after another along a straight line, and ' \
      'come back in the same order, on a period of sixty-one years. It emits nothing at any ' \
      'wavelength the Archive can hear.' },
  { 'id' => 'MOS-A05', 'x' => 1508.0, 'y' => 214.0, 'form' => 'arc', 'r' => 14,
    'observed' =>
      'Nine transits, identical in depth, spaced evenly around one orbit and holding that ' \
      'spacing for the eleven hundred years of the record. The star has no planets left.' }
]
anomalies = ANOMALIES.map { |a| a.merge('status' => 'unexplained') }

# ------------------------------------------------------------------ output --
# One object per line: small enough to ship in a page, still readable in a diff.
def block(name, arr, last = false)
  body = arr.map { |o| '    ' + JSON.generate(o) }.join(",\n")
  "  #{JSON.generate(name)}: [\n#{body}\n  ]#{last ? "\n" : ",\n"}"
end

counts = {
  'stars' => stars.size,
  'multiple' => stars.count { |s| s['comp'] },
  'wd' => stars.count { |s| s['kind'] == 'wd' },
  'pulsar' => stars.count { |s| s['kind'] == 'pulsar' },
  'bh' => stars.count { |s| s['kind'] == 'bh' },
  'deep' => deep.size, 'agn' => agn.size, 'anomalies' => anomalies.size
}

json = +"{\n"
json << "  \"seed\": #{SEED},\n"
json << "  \"bounds\": { \"w\": #{W}, \"h\": #{H} },\n"
json << "  \"named\": #{named.size},\n"
json << "  \"count\": #{stars.size},\n"
json << "  \"counts\": #{JSON.generate(counts)},\n"
json << block('stars', stars)
json << block('deep', deep)
json << block('agn', agn)
json << block('anomalies', anomalies, true)
json << "}\n"
File.write(File.join(ROOT, 'docs/_data/starfield.json'), json)

pts = stars.sum { |s| 1 + (s['comp'] || []).size }
puts "wrote #{stars.size} stellar systems / #{pts} points (#{named.size} named) -> docs/_data/starfield.json"
puts '  class mix: ' + CLASS_W.map { |k, _| "#{k}:#{stars.count { |s| s['cls'] == k }}" }.join('  ')
puts "  multiples: #{counts['multiple']} (#{(100.0 * counts['multiple'] / FIELD).round}% of the field)  " \
     "wd:#{counts['wd']}  pulsar:#{counts['pulsar']}  bh:#{counts['bh']}  smbh:1"
puts "  deep sky:  " + deep.group_by { |d| d['kind'] }.map { |k, v| "#{k}:#{v.size}" }.join('  ')
puts "  beyond:    agn:#{agn.size}  anomalies:#{anomalies.size} (unexplained, and staying that way)"
