#!/usr/bin/env ruby
# encoding: utf-8
#
# gen-art-manifest.rb — flatten the system data into an art job manifest.
#
# Each body in docs/_data/system-*.yml already carries its own `art.prompt` and
# `art.size`. This scans every system file and emits scripts/art/manifest.json —
# one flat asset per star/planet — which the stdlib generator (scripts/gen-art.py)
# consumes. Ruby owns YAML here (the site already depends on it), so gen-art.py
# stays dependency-free. Re-run whenever the system data or a prompt changes.
#
#     ruby scripts/gen-art-manifest.rb
#
# Bodies with `art: null` (the belt — drawn as specks, not a still) are skipped.
# NO mesh / temporal-transmitter art — that layer is private (planning/).

require 'json'
require 'yaml'
require 'fileutils'

ROOT = File.expand_path('..', __dir__)
OUT  = File.join(ROOT, 'scripts/art/manifest.json')

assets = []

Dir[File.join(ROOT, 'docs/_data/system-*.yml')].sort.each do |path|
  doc = YAML.load_file(path)
  sys = doc['system'] || {}
  sys_id = sys['id'] || File.basename(path, '.yml').sub(/^system-/, '')

  emit = lambda do |body, kind|
    art = body['art']
    return unless art.is_a?(Hash) && art['prompt']
    id = body['id']
    assets << {
      'system'  => sys_id,
      'id'      => id,
      'name'    => body['name'] || id,
      'kind'    => kind,
      'size'    => (art['size'] || '1024x1024'),
      'prompt'  => art['prompt'].to_s.strip.gsub(/\s+/, ' '),
      'out'     => "docs/assets/art/#{sys_id}/#{id}.png"
    }
  end

  (doc['stars'] || []).each { |s| emit.call(s, 'star') }
  (doc['bodies'] || []).each { |b| emit.call(b, b['kind'] || 'planet') }
end

FileUtils.mkdir_p(File.dirname(OUT))
File.write(OUT, JSON.pretty_generate({ 'count' => assets.size, 'assets' => assets }) + "\n")

puts "wrote #{assets.size} assets -> #{OUT.sub(ROOT + '/', '')}"
assets.each { |a| puts "  #{a['system']}/#{a['id']}  (#{a['kind']}, #{a['size']})" }
