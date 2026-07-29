---
layout: default
title: The Memory of Stars
description: A science-fantasy universe unfolding across thirty novellas.
---

<section class="hero">
  <p class="hero-eyebrow">A mythic science fiction universe · thirty novellas</p>
  <h1>The Memory of Stars</h1>
  <p class="hero-tagline">The greatest treasures are not planets, weapons, or technologies. They are&nbsp;memories.</p>
  <p class="hero-question">What must a civilization remember if it hopes to survive?</p>
  <div class="hero-actions">
    <a class="btn btn--primary" href="{{ '/books/' | relative_url }}">Explore the Books</a>
    <a class="btn btn--ghost" href="{{ '/lore/' | relative_url }}">Enter the Lore</a>
  </div>
</section>

<section class="section wrap">
  <div class="section-head">
    <h2>Begin the journey</h2>
    <p>Three ways into the universe.</p>
  </div>
  <div class="grid grid--3">
    <a class="card" href="{{ '/books/' | relative_url }}">
      <h3>✦ The Books</h3>
      <p>Thirty novellas charting the backstory of the universe — read them in order or wander.</p>
    </a>
    <a class="card" href="{{ '/lore/' | relative_url }}">
      <h3>✦ The Lore</h3>
      <p>Worlds, factions, characters, and the truth of what the stars remember.</p>
    </a>
    <a class="card" href="{{ '/about/' | relative_url }}">
      <h3>✦ About</h3>
      <p>What The Memory of Stars is, where it's going, and how to follow along.</p>
    </a>
  </div>
</section>

{% assign latest = site.posts | slice: 0, 3 %}
{% if latest.size > 0 %}
<section class="section wrap">
  <div class="section-head">
    <h2>Latest news</h2>
    <p><a href="{{ '/news/' | relative_url }}">All updates →</a></p>
  </div>
  <ul class="entry-list">
    {% for post in latest %}
    <li class="entry">
      <span class="meta">{{ post.date | date: "%b %-d, %Y" }}</span>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    </li>
    {% endfor %}
  </ul>
</section>
{% endif %}
