#!/usr/bin/env ruby
# encoding: utf-8
#
# build-reading.rb — generate the website's reading pages from the manuscripts.
#
# Single source of truth : manuscripts/cycle-*/book-*/manuscript.md
# Generated output       : docs/_reading/book-NN-<chapter>.md  (committed)
#
# Manuscripts are split on `## ` headings (Prologue / Chapter N / Epilogue).
# Chapters that are still placeholders (no prose yet) are skipped, so a chapter
# appears on the site only once it's written. Re-run after editing a manuscript:
#
#     ruby scripts/build-reading.rb
#
# Because GitHub Pages builds vanilla Jekyll (no Actions), commit the regenerated
# docs/_reading/ files alongside the manuscript change.

require 'yaml'
require 'fileutils'

ROOT = File.expand_path('..', __dir__)
MAN  = File.join(ROOT, 'manuscripts')
OUT  = File.join(ROOT, 'docs', '_reading')

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

FileUtils.mkdir_p(OUT)
Dir[File.join(OUT, '*.md')].each { |f| File.delete(f) }   # clear prior generation

count = 0
Dir[File.join(MAN, 'cycle-*', 'book-*')].sort.each do |dir|
  man = File.join(dir, 'manuscript.md')
  next unless File.file?(man)

  m = File.basename(dir).match(/\Abook-(\d+)-(.+)\z/)
  next unless m                       # skip untitled `book-NN` folders (no slug yet)
  num, slug = m[1], m[2]

  ch_audio = {}
  ap = File.join(dir, 'audio.yml')
  if File.file?(ap)
    (YAML.load_file(ap)['chapters'] rescue nil)&.each { |c| ch_audio[c['id']] = c }
  end

  text = File.read(man)
  book_title = (text[/^\#\s+(.+)$/, 1] || slug).strip

  text.split(/^\#\#\s+/).drop(1).each do |sec|
    heading, _, body = sec.partition("\n")
    body = body.gsub(/<!--.*?-->/m, '')
    next if body !~ /\p{Alpha}/       # placeholder chapter — not written yet

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
    }
    fm['mood'] = a['mood'] if a['mood']
    fm['pace'] = a['pace'] if a['pace']

    File.write(File.join(OUT, "book-#{num}-#{id}.md"), fm.to_yaml + "---\n\n#{prose}\n")
    count += 1
    puts "  book-#{num}-#{id}.md   (#{book_title} — #{label}: #{title})"
  end
end

puts "Generated #{count} reading page(s) into docs/_reading/"
