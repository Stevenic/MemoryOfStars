---
layout: page
title: The Books
subtitle: Thirty novellas that build the universe of The Memory of Stars.
permalink: /books/
---

{% assign books = site.books | sort: "number" %}
{% if books.size > 0 %}
<ul class="entry-list">
  {% for book in books %}
  <li class="entry">
    <span class="num">{{ book.number }}</span>
    <a href="{{ book.url | relative_url }}">{{ book.title }}</a>
    {% if book.status %}<span class="meta">{{ book.status }}</span>{% endif %}
  </li>
  {% endfor %}
</ul>
{% else %}
<p class="lead">The first novellas are on their way. Check back soon.</p>
{% endif %}

---

Each entry gets its own page as it's ready. To add one, drop a Markdown file into
`docs/_books/` — see `docs/_books/book-01.md` for the shape.
