---
layout: page
title: Lore
subtitle: The worldbuilding of The Memory of Stars — spoiler-light unless noted.
permalink: /lore/
---

{% assign entries = site.lore | sort: "title" %}
{% if entries.size > 0 %}
<ul class="entry-list">
  {% for entry in entries %}
  <li class="entry">
    <a href="{{ entry.url | relative_url }}">{{ entry.title }}</a>
    {% if entry.category %}<span class="meta">{{ entry.category }}</span>{% endif %}
  </li>
  {% endfor %}
</ul>
{% else %}
<p class="lead">The archives are opening. Lore entries will appear here.</p>
{% endif %}

---

Add an entry by dropping a Markdown file into `docs/_lore/` — see
`docs/_lore/the-memory-of-stars.md` for the shape.
