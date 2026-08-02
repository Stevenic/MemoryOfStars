#!/usr/bin/env ruby
# encoding: utf-8
#
# gen-chart.rb — wire the accurate chart: Bell-frame 3-D truth -> plate positions.
#
# Reads series-bible/bell-frame.yml (positions), series-bible/systems/*.yml (star
# classes), series-bible/mesh-routes.yml (the route graph), and the committed
# production sky (docs/_data/starfield.json + stars-named.yml, whose Auros pin
# anchors the projection). Emits TWO LOCAL, GITIGNORED preview artifacts:
#
#   docs/_data/starfield_full.json — the production sky + every gazetteer star at
#       its projected plate position + the full route graph ("routes")
#   docs/_data/systems_full.json   — every system file bundled by system id
#
# Production data is NOT touched: the public sky learns a star only when its book
# publishes (copy the star's pin printed below into stars-named.yml, its system
# file into docs/_data/, and its routes into the production sky at that time).
#
# Projection: the plate is a full-sky panorama. Longitude (atan2(y,x) in the
# galactic plane) maps to x; latitude rides the band line band_y(x) with a fixed
# px/deg scale; both constants are SOLVED from Auros's committed pin, so the one
# published star never moves. The vantage is the frame's origin, and the chart
# does not say so.
#
#     ruby scripts/gen-chart.rb

require 'json'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
W, H = 2000.0, 1200.0

bell    = YAML.load_file(File.join(ROOT, 'series-bible', 'bell-frame.yml'))
routes  = YAML.load_file(File.join(ROOT, 'series-bible', 'mesh-routes.yml'))['routes']
named   = YAML.load_file(File.join(ROOT, 'docs', '_data', 'stars-named.yml'))['stars']
base    = JSON.parse(File.read(File.join(ROOT, 'docs', '_data', 'starfield.json')))

def band_y(x) = H * (0.24 + 0.52 * x / W)

# --- solve the projection from the anchor (Auros) ---
anchor  = named.find { |s| s['id'] == 'auros' } or abort 'no auros pin in stars-named.yml'
enara   = bell['systems'].find { |s| s['id'] == 'enara' }
alon    = Math.atan2(enara['y'], enara['x']) * 180 / Math::PI
alat    = Math.asin(enara['z'] / Math.sqrt(enara['x']**2 + enara['y']**2 + enara['z']**2)) * 180 / Math::PI
OFF     = anchor['x'] / W * 360.0 - alon
LATS    = (anchor['y'] - band_y(anchor['x'].to_f)) / alat
R_ANCH  = Math.sqrt(enara['x']**2 + enara['y']**2 + enara['z']**2)

CLS_OFF = { 'O' => -0.5, 'B' => -0.3, 'A' => 0.0, 'F' => 0.1, 'G' => 0.2, 'K' => 0.5, 'M' => 1.1 }

# star class per system, from the system files
cls_by_id = {}
name_by_id = {}
systems_bundle = {}
(Dir[File.join(ROOT, 'series-bible', 'systems', 'system-*.yml')] +
 [File.join(ROOT, 'docs', '_data', 'system-orin.yml')]).each do |f|
  d = YAML.load_file(f)
  sid = d.dig('system', 'id') or next
  systems_bundle[sid] = d
  star = (d['stars'] || []).first || {}
  key  = sid.sub(/-system$/, '')
  key  = 'enara' if key == 'orin'
  cls_by_id[key]  = (star['spectral'] || 'G')[0]
  name_by_id[key] = star['name']
end

pins = []
extra = []
bell['systems'].each do |s|
  next if s['id'] == 'enara'   # published; its committed pin is the anchor
  x3, y3, z3 = s['x'].to_f, s['y'].to_f, s['z'].to_f
  r   = Math.sqrt(x3**2 + y3**2 + z3**2)
  r   = 1.0 if r < 1.0
  lon = Math.atan2(y3, x3) * 180 / Math::PI
  lat = Math.asin(z3 / r) * 180 / Math::PI
  px  = ((lon + OFF) % 360.0) / 360.0 * W
  py  = (band_y(px) + LATS * lat).clamp(26.0, H - 26.0)
  cls = cls_by_id[s['id']] || 'K'
  mag = (0.9 + 5 * Math.log10(r / R_ANCH) + (CLS_OFF[cls] || 0.4)).clamp(0.6, 5.4)
  mag = 4.9 if s['id'] == 'hearth'   # the origin can't project its own distance; keep it faint
  nm  = s['star'] || name_by_id[s['id']] || s['world'] || s['id'].capitalize
  row = { 'id' => s['id'], 'name' => nm, 'x' => px.round(1), 'y' => py.round(1),
          'cls' => cls, 'mag' => mag.round(2),
          'refs' => (s['books'] || []).map { |b| format('book-%02d', b) },
          'system' => "#{s['id'] == 'enara' ? 'orin' : s['id']}-system",
          'note' => s['note'] }
  extra << row
  pins << format('%-9s x %6.1f  y %6.1f  cls %s  mag %4.2f  reveal %s',
                 s['id'], px, py, cls, mag, row['refs'].first)
end

full = base.dup
full['stars']  = base['stars'] + extra
full['named']  = (base['named'] || 1) + extra.length
full['routes'] = routes
File.write(File.join(ROOT, 'docs', '_data', 'starfield_full.json'), JSON.generate(full))
File.write(File.join(ROOT, 'docs', '_data', 'systems_full.json'), JSON.generate(systems_bundle))

puts "starfield_full.json: #{full['stars'].length} stars (#{extra.length} unrevealed pins) + #{routes.length} routes"
puts "systems_full.json:   #{systems_bundle.length} systems"
puts "\n— wiring pins (copy into stars-named.yml when each book publishes) —"
pins.each { |p| puts '  ' + p }
