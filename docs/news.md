---
layout: page
title: News
subtitle: Updates on the writing, releases, and the wider universe.
permalink: /news/
---

{% if site.posts.size > 0 %}
<ul class="entry-list">
  {% for post in site.posts %}
  <li class="entry">
    <span class="meta">{{ post.date | date: "%b %-d, %Y" }}</span>
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
  </li>
  {% endfor %}
</ul>
{% else %}
<p class="lead">No posts yet.</p>
{% endif %}
