#!/usr/bin/env ruby
# encoding: utf-8
#
# build-reading.rb — generate the website's reading pages from the manuscripts.
#
# Single source of truth : manuscripts/cycle-*/book-*/manuscript.md
# Generated output       : docs/_reading/book-NN-<chapter>.md          (committed)
#                          docs/_data/reading_versions.yml             (committed)
#
# Manuscripts are split on `## ` headings (Prologue / Chapter N / Epilogue).
# Chapters that are still placeholders (no prose yet) are skipped, so a chapter
# appears on the site only once it's written. Re-run after editing a manuscript:
#
#     ruby scripts/build-reading.rb
#
# VERSIONS
# --------
# A book folder may contain a `versions.yml` manifest declaring several readable
# versions of the same book (e.g. an original draft and a revised pass). When it is
# present, this script emits one set of reading pages PER version and records the
# version list in docs/_data/reading_versions.yml, which drives the reader's version
# picker. The `default` version keeps the plain /read/book-NN-<chapter>/ URLs (so
# existing links never break); other versions are namespaced /read/book-NN-<id>-...
# When no manifest is present, the book renders as a single version from
# manuscript.md exactly as before (no picker).
#
# Because GitHub Pages builds vanilla Jekyll (no Actions), commit the regenerated
# docs/_reading/ files and docs/_data/reading_versions.yml alongside manuscript edits.

require 'yaml'
require 'fileutils'

ROOT = File.expand_path('..', __dir__)
MAN  = File.join(ROOT, 'manuscripts')
OUT  = File.join(ROOT, 'docs', '_reading')
DATA = File.join(ROOT, 'docs', '_data')

SCENE = /\A\s*(?:⸻|\*\s*\*\s*\*|-{3,})\s*\z/

def slugify(s)
  s.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/\A-|-\z/, '')
end

# → [order, id, label] from a heading like "Chapter 3 — The Festival of Last Things"
def classify(heading)
  left = heading.split(/\s[—–-]\s/, 2).first.strip
  case left
  when /\Aprologue\z/i         then [0,    'prologue',        'Prologue']
  when /\Aepilogue\z/i         then [1000, 'epilogue',        'Epilogue']
  when /\Achapter\s+(\d+)/i    then [$1.to_i, "chapter-#{$1}", "Chapter #{$1}"]
  else                              [500,  slugify(left),     left]
  end
end

# Resolve the version list for a book folder.
# Returns an array of { 'id','label','file','note','default' }. Books without a
# versions.yml get a single implicit version backed by manuscript.md.
def load_versions(dir)
  vf = File.join(dir, 'versions.yml')
  unless File.file?(vf)
    return [{ 'id' => 'base', 'label' => nil, 'file' => 'manuscript.md',
              'note' => nil, 'default' => true }]
  end
  data = YAML.load_file(vf) || {}
  default_id = data['default']
  vs = (data['versions'] || []).map do |v|
    { 'id'      => v['id'],
      'label'   => v['label'] || v['id'],
      'file'    => v['file'] || 'manuscript.md',
      'note'    => v['note'],
      'default' => v['id'] == default_id }
  end
  vs.first['default'] = true if vs.any? && vs.none? { |v| v['default'] }
  vs
end

FileUtils.mkdir_p(OUT)
FileUtils.mkdir_p(DATA)
Dir[File.join(OUT, '*.md')].each { |f| File.delete(f) }   # clear prior generation

reading_versions = {}   # book_slug => [ {id,label,note,default}, ... ] for multi-version books
count = 0

Dir[File.join(MAN, 'cycle-*', 'book-*')].sort.each do |dir|
  m = File.basename(dir).match(/\Abook-(\d+)-(.+)\z/)
  next unless m                       # skip untitled `book-NN` folders (no slug yet)
  num, slug = m[1], m[2]

  ch_audio = {}                       # prosody is shared across versions (keyed by chapter id)
  ap = File.join(dir, 'audio.yml')
  if File.file?(ap)
    (YAML.load_file(ap)['chapters'] rescue nil)&.each { |c| ch_audio[c['id']] = c }
  end

  versions = load_versions(dir)
  if versions.length > 1             # only advertise a picker when there's a real choice
    reading_versions[slug] = versions.map do |v|
      { 'id' => v['id'], 'label' => v['label'], 'note' => v['note'], 'default' => v['default'] }
    end
  end

  versions.each do |ver|
    man = File.join(dir, ver['file'])
    next unless File.file?(man)

    text = File.read(man)
    book_title = (text[/^\#\s+(.+)$/, 1] || slug).strip

    text.split(/^\#\#\s+/).drop(1).each do |sec|
      heading, _, body = sec.partition("\n")
      body = body.gsub(/<!--.*?-->/m, '')
      next if body !~ /\p{Alpha}/     # placeholder chapter — not written yet

      order, id, label = classify(heading.strip)
      title = (heading.strip.split(/\s[—–-]\s/, 2)[1] || heading).strip
      a = ch_audio[id] || {}

      prose = body.strip.split("\n").map do |ln|
        ln =~ SCENE ? '<div class="scene-break" aria-hidden="true">⸻</div>' : ln
      end.join("\n")

      fm = {
        'layout' => 'chapter', 'book_title' => book_title, 'book_number' => num,
        'book_slug' => slug, 'book_url' => "/books/book-#{num}/",
        'label' => label, 'title' => title, 'order' => order, 'generated' => true,
        'version_id' => ver['id'], 'chapter_key' => id,
      }
      fm['version_label'] = ver['label'] if ver['label']
      fm['mood'] = a['mood'] if a['mood']
      fm['pace'] = a['pace'] if a['pace']

      # The default version keeps the plain URL; others are namespaced by version id.
      name = ver['default'] ? "book-#{num}-#{id}" : "book-#{num}-#{ver['id']}-#{id}"

      File.write(File.join(OUT, "#{name}.md"), fm.to_yaml + "---\n\n#{prose}\n")
      count += 1
      puts "  #{name}.md   (#{book_title} — #{ver['label'] || 'single'} — #{label}: #{title})"
    end
  end
end

# Write the data file that drives the reader's version picker.
header = "# Generated by scripts/build-reading.rb — do not edit by hand.\n" \
         "# Books with multiple reading versions; keyed by book_slug.\n"
body = reading_versions.empty? ? "{}\n" : YAML.dump(reading_versions).sub(/\A---\n/, '')
File.write(File.join(DATA, 'reading_versions.yml'), header + body)

puts "Generated #{count} reading page(s) into docs/_reading/"
puts "Version manifest: docs/_data/reading_versions.yml (#{reading_versions.keys.size} multi-version book(s))"
