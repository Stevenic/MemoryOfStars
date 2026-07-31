---
layout: default
title: Step Inside
permalink: /step-inside/
description: Step into a recorded memory of Memory of Stars — inhabit someone who was there, and walk the world. Powered by your own Anthropic API key.
---
<script>
  /* The world DB + star index, injected at build time from docs/_data/ */
  window.SI_ARCHIVE = {{ site.data.archive | jsonify }};
  window.SI_INDEX = {{ site.data.archive_index | jsonify }};
  /* Private roadmap overlay — the file is gitignored, so this is null in production
     and the public map keeps its dark, unnamed stars. */
  window.SI_INDEX_FULL = {{ site.data.archive_index_full | jsonify }};
  window.SI_BASEURL = "{{ site.baseurl }}";
</script>
{% raw %}
<section class="si-intro wrap">
  <p class="eyebrow">The Archive</p>
  <h1>The Memory of Stars</h1>
  <p class="lead">A sky of stars — far more than have names. The lit ones hold recorded
  moments you can step inside: inhabit someone who was there, wander the world, talk to
  the people. It's a memory — you can touch it, but you can't change what was. The rest
  of the sky is uncharted: stories not yet told.</p>
  <p class="si-note">Runs on <strong>your own Anthropic API key</strong> — the world is
  conjured live, so it uses your API credits. The key lives only in this browser.
  <button type="button" class="si-link" id="si-open-settings-inline">Settings</button></p>
</section>

<!-- ENTRY: the constellation (Archive index) -->
<section class="si-scenes wrap" id="si-entry">
  <p class="si-preview-badge" id="si-preview-badge" hidden>Roadmap preview — local only. Production shows these stars dark and unnamed.</p>
  <div class="si-map-wrap">
    <div class="si-map-ui">
      <label class="si-map-toggle"><input type="checkbox" id="si-show-lines"> constellations</label>
      <button type="button" id="si-map-reset" title="Reset view" aria-label="Reset view">⌖</button>
    </div>
    <svg id="si-map" viewBox="0 0 1200 640" role="img"
         aria-label="An interactive star chart. Drag to pan, scroll to zoom. Lit stars hold recordings."></svg>
  </div>
  <div class="si-star-panel" id="si-star-panel">
    <span class="si-sp-cycle" id="si-sp-cycle">&nbsp;</span>
    <span class="si-sp-title" id="si-sp-title">Choose a star</span>
    <span class="si-sp-facet" id="si-sp-facet"></span>
    <span class="si-sp-blurb" id="si-sp-blurb"></span>
    <span class="si-sp-status" id="si-sp-status">Drag to pan · scroll to zoom · the lit stars hold recordings.</span>
  </div>
  <h2 class="si-rec-head" id="si-rec-head" hidden>Open a memory</h2>
  <div class="si-scene-grid" id="si-entry-grid"></div>
</section>

<!-- INHABIT: choose a body -->
<section class="si-scenes wrap" id="si-inhabit" hidden>
  <button type="button" class="si-back" id="si-inhabit-back">← back</button>
  <h2 id="si-inhabit-title">Whose eyes?</h2>
  <p class="si-note" id="si-inhabit-frame"></p>
  <div class="si-scene-grid" id="si-inhabit-grid"></div>
</section>

<!-- THE ROOM -->
<section class="si-room" id="si-room" hidden>
  <header class="si-room-head wrap">
    <button type="button" class="si-back" id="si-leave">← step out</button>
    <div class="si-room-title">
      <span class="si-room-name" id="si-room-name"></span>
      <span class="si-room-when" id="si-room-when"></span>
    </div>
    <button type="button" class="si-gear" id="si-open-settings" title="Settings" aria-label="Settings">⚙</button>
  </header>

  <div class="si-transcript" id="si-transcript" aria-live="polite"></div>

  <form class="si-composer wrap" id="si-composer">
    <textarea id="si-input" rows="1" placeholder="Look around, or say something…" autocomplete="off"></textarea>
    <button type="submit" id="si-send">Send</button>
  </form>
  <p class="si-hint wrap">Try: <em>look around</em> · <em>who's here?</em> · <em>go to the market</em> · <em>ask her what she's afraid of</em> · <em>pick up the red bird</em></p>

  <!-- boundary warning -->
  <div class="si-boundary" id="si-boundary" hidden>
    <div class="si-boundary-inner wrap">
      <p><strong>You've reached the edge of this memory.</strong> There's nothing recorded past here.</p>
      <div class="si-boundary-actions">
        <button type="button" class="si-btn-ghost" id="si-boundary-leave">Leave the Archive</button>
        <button type="button" class="si-btn-primary" id="si-boundary-stay">Stay (step back)</button>
      </div>
    </div>
  </div>
</section>

<!-- SETTINGS MODAL -->
<div class="si-modal-scrim" id="si-modal" hidden>
  <div class="si-modal" role="dialog" aria-modal="true" aria-labelledby="si-modal-title">
    <h2 id="si-modal-title">Before you step inside</h2>
    <p class="si-modal-sub">This calls Anthropic's API directly from your browser, so it needs
    your own key. Nothing is sent anywhere else.</p>
    <label class="si-field">
      <span>Anthropic API key</span>
      <input type="password" id="si-key" placeholder="sk-ant-…" autocomplete="off" spellcheck="false">
      <small>Stored only in this browser (localStorage). Get one at
        <a href="https://console.anthropic.com/settings/keys" target="_blank" rel="noopener">console.anthropic.com</a>.</small>
    </label>
    <label class="si-field">
      <span>Model</span>
      <select id="si-model"></select>
      <small id="si-model-hint"></small>
    </label>
    <p class="si-resolved">Requests will use: <code id="si-model-resolved"></code></p>
    <details class="si-advanced">
      <summary>Advanced</summary>
      <label class="si-field">
        <span>Custom model ID <em>(optional — overrides the choice above)</em></span>
        <input type="text" id="si-model-custom" placeholder="e.g. claude-opus-4-8 (leave empty to use the picker)" autocomplete="off" spellcheck="false">
        <small>Only for IDs not in the list above. <strong>Leave empty</strong> otherwise — a wrong ID here breaks every call.</small>
      </label>
    </details>
    <div class="si-modal-actions">
      <button type="button" class="si-btn-ghost" id="si-clear-key">Forget key</button>
      <span class="si-spacer"></span>
      <button type="button" class="si-btn-ghost" id="si-cancel">Cancel</button>
      <button type="button" class="si-btn-primary" id="si-save">Save</button>
    </div>
    <p class="si-modal-foot">Keeping an API key in a browser is fine for personal use — just not on a shared computer.</p>
  </div>
</div>

<style>
.si-intro { padding-block: 2.5rem 1rem; }
.si-intro h1 { font-size: clamp(2rem, 5vw, 3rem); margin: .2rem 0 .8rem; }
.si-note { color: var(--muted); font-size: .92rem; max-width: 62ch; }
.si-link { background: none; border: none; color: var(--gold); cursor: pointer; font: inherit; padding: 0; text-decoration: underline; }

.si-scenes { padding-block: 1rem 4rem; }
.si-scenes h2 { font-size: 1.5rem; margin: 0 0 .4rem; }
.si-scene-grid { display: grid; gap: 1.1rem; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); margin-top: 1.2rem; }
.si-scene-card {
  text-align: left; cursor: pointer; color: var(--text);
  background: linear-gradient(180deg, var(--panel), var(--panel-2));
  border: 1px solid var(--border); border-radius: var(--radius);
  padding: 1.3rem; transition: transform .15s ease, border-color .15s ease;
  display: flex; flex-direction: column; gap: .5rem; font: inherit;
}
.si-scene-card:hover { transform: translateY(-3px); border-color: var(--gold); }
.si-scene-card .si-sc-tag { color: var(--gold); font-size: .7rem; letter-spacing: .14em; text-transform: uppercase; }
.si-scene-card .si-sc-name { font-family: "Iowan Old Style", Palatino, Georgia, serif; font-size: 1.3rem; }
.si-scene-card .si-sc-blurb { color: var(--muted); font-size: .92rem; }

/* --- The constellation (Archive index) --- */
.si-map-wrap {
  border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden;
  aspect-ratio: 1200 / 640;
  background:
    radial-gradient(900px 420px at 68% -8%, rgba(122,162,255,.14), transparent 60%),
    radial-gradient(700px 380px at 12% 108%, rgba(233,196,106,.07), transparent 60%),
    var(--bg);
}
.si-map-wrap { position: relative; }
#si-map { display: block; width: 100%; height: 100%; touch-action: none; cursor: grab; }
#si-map:active { cursor: grabbing; }
.si-map-ui { position: absolute; top: .6rem; right: .6rem; display: flex; gap: .45rem; align-items: center; z-index: 2; }
.si-map-toggle {
  display: inline-flex; gap: .4rem; align-items: center; cursor: pointer;
  color: var(--muted); font-size: .75rem; letter-spacing: .05em;
  background: rgba(10,14,26,.6); border: 1px solid var(--border); border-radius: 999px;
  padding: .3rem .75rem; backdrop-filter: blur(4px);
}
.si-map-toggle input { accent-color: var(--gold); }
#si-map-reset {
  background: rgba(10,14,26,.6); border: 1px solid var(--border); color: var(--muted);
  border-radius: 999px; width: 1.9rem; height: 1.9rem; cursor: pointer; font: inherit;
}
#si-map-reset:hover, .si-map-toggle:hover { border-color: var(--gold); color: var(--gold); }
.si-grid { stroke: rgba(207,224,255,.045); stroke-width: 1; }
.si-arc { fill: none; stroke: rgba(233,196,106,.07); stroke-width: 1; }
.si-fstar { fill: #cfe0ff; }
.si-fstar { cursor: pointer; }
.si-twinkle { animation-name: si-tw; animation-timing-function: ease-in-out; animation-iteration-count: infinite; }
@keyframes si-tw { 0%, 100% { opacity: .65; } 50% { opacity: .06; } }
.si-lines { transition: opacity .35s ease; }
.si-dust { fill: #cfe0ff; }
.si-cline { stroke: rgba(207,224,255,.22); stroke-width: 1; }
.si-cline--dark { stroke: rgba(207,224,255,.06); }
.si-clabel { fill: var(--gold); font-size: 13px; letter-spacing: .22em; text-transform: uppercase; opacity: .75; }
.si-star { cursor: pointer; outline: none; }
.si-star .halo { fill: var(--gold); opacity: 0; }
.si-star .core { fill: #cfe0ff; transition: opacity .15s ease; }
.si-star--blaze .core { fill: var(--gold); }
.si-star--blaze .halo { animation: si-pulse 2.6s ease-in-out infinite; }
.si-star--published .core { fill: #ffffff; opacity: .92; }
.si-star--writing .core { animation: si-flicker 3.2s linear infinite; }
.si-star--planned .core { opacity: .48; }
.si-star--dark .core { opacity: .15; }
.si-star:hover .core, .si-star:focus .core, .si-star.is-selected .core { opacity: 1; fill: var(--gold-soft); }
.si-star.is-selected .ring { stroke: var(--gold); opacity: .8; }
.si-star .ring { fill: none; stroke: transparent; stroke-width: 1; opacity: 0; }
@keyframes si-pulse { 0%,100% { opacity: .07; } 50% { opacity: .28; } }
@keyframes si-flicker {
  0%,100% { opacity: .85; } 8% { opacity: .3; } 12% { opacity: .8; } 34% { opacity: .55; }
  38% { opacity: .9; } 61% { opacity: .35; } 66% { opacity: .8; }
}
@media (max-width: 560px) { .si-clabel { display: none; } }

.si-star-panel {
  margin-top: 1.1rem; padding: 1rem 1.2rem;
  border: 1px solid var(--border); border-radius: var(--radius);
  background: linear-gradient(180deg, var(--panel), var(--panel-2));
  display: flex; flex-direction: column; gap: .15rem;
}
.si-sp-cycle { color: var(--gold); font-size: .68rem; letter-spacing: .2em; text-transform: uppercase; min-height: 1em; }
.si-sp-title { font-family: "Iowan Old Style", Palatino, Georgia, serif; font-size: 1.35rem; color: var(--text); }
.si-sp-facet { color: var(--muted); font-style: italic; font-size: .92rem; }
.si-sp-blurb { color: var(--star); font-size: .9rem; margin-top: .25rem; }
.si-sp-status { color: var(--muted); font-size: .85rem; margin-top: .3rem; }
.si-preview-badge {
  display: inline-block; margin: 0 0 1rem; padding: .35rem .9rem;
  border: 1px dashed var(--gold); border-radius: 999px;
  color: var(--gold); font-size: .75rem; letter-spacing: .06em;
}
.si-preview-badge[hidden] { display: none; }
.si-rec-head { font-size: 1.2rem; margin: 1.6rem 0 0; }

.si-room { max-width: 44rem; margin: 0 auto; padding: 1rem 1.25rem 2rem; }
.si-room-head { display: flex; align-items: center; gap: 1rem; padding: 0 0 1rem; border-bottom: 1px solid var(--border); }
.si-room-title { flex: 1; text-align: center; display: flex; flex-direction: column; }
.si-room-name { font-family: "Iowan Old Style", Palatino, Georgia, serif; font-size: 1.15rem; color: var(--text); }
.si-room-when { color: var(--gold); font-size: .66rem; letter-spacing: .14em; text-transform: uppercase; }
.si-back, .si-gear { background: none; border: 1px solid var(--border); color: var(--muted); border-radius: 999px; cursor: pointer; font: inherit; }
.si-back { padding: .35rem .8rem; font-size: .85rem; }
.si-gear { width: 2.1rem; height: 2.1rem; font-size: 1rem; }
.si-back:hover, .si-gear:hover { border-color: var(--gold); color: var(--gold); }

.si-transcript { font-family: "Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif; font-size: 1.18rem; line-height: 1.8; color: #eef1fb; padding: 1.5rem 0; min-height: 40vh; }
.si-msg { margin: 0 0 1.3rem; white-space: pre-wrap; }
.si-you { color: var(--gold-soft); }
.si-you::before { content: "You: "; color: var(--gold); font-variant-caps: small-caps; }
.si-typing { color: var(--muted); font-style: italic; }
.si-error { color: #ffb4a2; font-size: .95rem; border-left: 3px solid #ffb4a2; padding-left: .8rem; }

.si-composer { display: flex; gap: .6rem; align-items: flex-end; max-width: 44rem; }
.si-composer textarea { flex: 1; resize: none; background: var(--panel); color: var(--text); border: 1px solid var(--border); border-radius: 12px; padding: .7rem .9rem; font: inherit; font-size: 1rem; line-height: 1.5; max-height: 40vh; }
.si-composer textarea:focus { outline: none; border-color: var(--gold); }
#si-send { background: var(--gold); color: #201803; border: none; border-radius: 999px; padding: .7rem 1.3rem; font-weight: 600; cursor: pointer; font: inherit; font-size: .95rem; }
#si-send:disabled { opacity: .5; cursor: default; }
.si-hint { color: var(--muted); font-size: .82rem; margin: .7rem auto 0; max-width: 44rem; }
.si-hint em { color: var(--star); font-style: normal; }

.si-boundary { position: sticky; bottom: 0; margin-top: 1rem; }
.si-boundary-inner { background: linear-gradient(180deg, rgba(20,27,51,.96), rgba(26,34,66,.98)); border: 1px solid var(--gold); border-radius: var(--radius); padding: 1.1rem 1.3rem; backdrop-filter: blur(6px); }
.si-boundary-inner p { margin: 0 0 .8rem; color: var(--text); font-size: .95rem; }
.si-boundary-actions { display: flex; gap: .6rem; justify-content: flex-end; }

.si-modal-scrim { position: fixed; inset: 0; z-index: 100; display: grid; place-items: center; background: rgba(5,8,16,.78); backdrop-filter: blur(6px); padding: 1.25rem; }
.si-modal-scrim[hidden] { display: none; }   /* author display:grid would otherwise defeat the hidden attribute */
.si-modal { width: 100%; max-width: 30rem; background: linear-gradient(180deg, var(--panel), var(--panel-2)); border: 1px solid var(--border); border-radius: var(--radius); padding: 1.6rem; }
.si-modal h2 { font-size: 1.4rem; margin: 0 0 .3rem; }
.si-modal-sub { color: var(--muted); font-size: .9rem; margin: 0 0 1.2rem; }
.si-field { display: block; margin-bottom: 1.1rem; }
.si-field > span { display: block; font-size: .85rem; color: var(--text); margin-bottom: .35rem; }
.si-field > span em { color: var(--muted); font-style: normal; }
.si-field input, .si-field select { width: 100%; background: var(--bg-soft); color: var(--text); border: 1px solid var(--border); border-radius: 9px; padding: .6rem .7rem; font: inherit; }
.si-field input:focus, .si-field select:focus { outline: none; border-color: var(--gold); }
.si-field small { display: block; color: var(--muted); font-size: .78rem; margin-top: .35rem; }
.si-field small a { color: var(--gold); }
.si-resolved { color: var(--muted); font-size: .8rem; margin: -.4rem 0 1rem; }
.si-resolved code { color: var(--gold); background: var(--bg-soft); border: 1px solid var(--border); border-radius: 6px; padding: .1em .45em; }
.si-advanced { margin: -.3rem 0 1rem; }
.si-advanced summary { color: var(--muted); font-size: .85rem; cursor: pointer; }
.si-modal-actions { display: flex; align-items: center; gap: .6rem; margin-top: .4rem; }
.si-spacer { flex: 1; }
.si-btn-primary { background: var(--gold); color: #201803; border: none; border-radius: 999px; padding: .55rem 1.3rem; font-weight: 600; cursor: pointer; font: inherit; }
.si-btn-ghost { background: none; border: 1px solid var(--border); color: var(--muted); border-radius: 999px; padding: .55rem 1rem; cursor: pointer; font: inherit; }
.si-btn-ghost:hover { border-color: var(--gold); color: var(--gold); }
.si-modal-foot { color: var(--muted); font-size: .78rem; margin: 1rem 0 0; }
@media (max-width: 480px) { .si-transcript { font-size: 1.08rem; } }
</style>

<script>
(function () {
  "use strict";
  var ARCHIVE = window.SI_ARCHIVE || {};
  var LS = { key: "mos_api_key", model: "mos_model", custom: "mos_model_custom" };
  var MODELS = {
    sonnet: { label: "Sonnet 5", hint: "The best mix of speed and intelligence — recommended.", id: "claude-sonnet-5" },
    haiku:  { label: "Haiku 4.5", hint: "Fastest and cheapest.", id: "claude-haiku-4-5" },
    opus:   { label: "Opus 5", hint: "Deeper, more vivid narration; slower and pricier.", id: "claude-opus-5" },
    fable:  { label: "Fable 5", hint: "Anthropic's most capable model; premium price.", id: "claude-fable-5" }
  };
  var DEFAULT_MODEL = "sonnet";
  var API_URL = "https://api.anthropic.com/v1/messages";

  var TOOLS = [
    { name: "enter_location",
      description: "Resolve the space around the visitor. Call this once at the very start, and every time the visitor moves. Returns the place, who and what is present, and the ways out. Use only a location id that appears as a 'ways_out' target of the current place (or the visitor's start). If the visitor moves toward the edge of the recording, this returns a boundary — narrate the memory fraying, and stop.",
      input_schema: { type: "object", properties: { location_id: { type: "string", description: "the id of the place to enter" } }, required: ["location_id"] } },
    { name: "examine",
      description: "Get the true, canon-accurate detail of a specific person or thing before you describe it — a named character, or an object the visitor looks at, picks up, or opens. Returns how they speak, what they know, and what they must withhold. Prefer this over inventing anything that matters.",
      input_schema: { type: "object", properties: { subject: { type: "string", description: "the person or thing, e.g. 'Mara' or 'the red bird'" } }, required: ["subject"] } },
    { name: "recall",
      description: "Look up general knowledge the visitor asks about that is not in front of them — a custom, a place elsewhere, someone not present. Returns only what a person here could know. If it finds nothing, keep the matter a mystery: do not invent an answer or describe anything beyond this recording.",
      input_schema: { type: "object", properties: { query: { type: "string" } }, required: ["query"] } }
  ];

  var state = { sliceId: null, body: null, location: null, messages: [], busy: false };
  var snapshot = null, turnEls = [], pendingOpen = null;

  var $ = function (id) { return document.getElementById(id); };
  var modal = $("si-modal"), entry = $("si-entry"), inhabit = $("si-inhabit"), room = $("si-room"),
      transcript = $("si-transcript"), input = $("si-input"), composer = $("si-composer"),
      sendBtn = $("si-send"), modelSel = $("si-model"), boundaryBox = $("si-boundary");

  // ---- helpers ----
  function slice() { return ARCHIVE[state.sliceId]; }
  function norm(s) { return (s || "").toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ").trim(); }
  function objName(id) { return id.replace(/-/g, " "); }
  function dispName(map, id) { return (map[id] && map[id].name) ? map[id].name : objName(id); }
  function findId(map, q) {
    q = norm(q); if (!q) return null;
    var ids = Object.keys(map || {});
    for (var i = 0; i < ids.length; i++) {
      var id = ids[i], sid = norm(id.replace(/-/g, " ")), nm = norm(dispName(map, id));
      if (q.indexOf(sid) >= 0 || sid.indexOf(q) >= 0 || (nm && (q.indexOf(nm) >= 0 || nm.indexOf(q) >= 0))) return id;
    }
    return null;
  }
  function subMap(map, ids) { var m = {}; (ids || []).forEach(function (id) { if (map[id]) m[id] = map[id]; }); return m; }
  function charRec(s, id) { var c = s.characters[id]; return c ? { id: id, name: c.name, voice: c.voice, knows: c.knows, withholds: c.withholds } : null; }

  // ---- tool resolution (local, against the world DB) ----
  function resolveTool(name, inp) {
    var s = slice();
    if (name === "enter_location") {
      var id = inp.location_id, loc = s.locations[id];
      if (loc) {
        state.location = id;
        return { location: {
          id: id, name: loc.name, vibe: loc.vibe,
          here: (loc.present || []).map(function (c) { return charRec(s, c); }).filter(Boolean),
          things: (loc.objects || []).map(function (o) { return { id: o, name: dispName(s.objects, o) }; }),
          ways_out: (loc.exits || []).map(function (e) { return { to: e.to, name: (s.locations[e.to] ? s.locations[e.to].name : objName(e.to)), note: e.note, boundary: !!e.boundary }; })
        } };
      }
      var edges = (s.boundaries && s.boundaries.edges) || {};
      if (edges[id]) return { boundary: true, edge: id, note: edges[id], fraying: s.boundaries.fraying };
      return { error: "There is no way to reach '" + id + "' from here." };
    }
    if (name === "examine") {
      var loc2 = s.locations[state.location] || {};
      var cid = findId(subMap(s.characters, loc2.present), inp.subject) || findId(s.characters, inp.subject);
      if (cid) { var c = s.characters[cid]; return { kind: "character", name: c.name, voice: c.voice, knows: c.knows, withholds: c.withholds }; }
      var oid = findId(subMap(s.objects, loc2.objects), inp.subject) || findId(s.objects, inp.subject);
      if (oid) { var o = s.objects[oid]; return { kind: "object", name: dispName(s.objects, oid), detail: o.public, withholds: o.withholds }; }
      return { found: false, note: "Nothing here answers to that. Look around, or recall for things not in view. Do not invent canon." };
    }
    if (name === "recall") {
      var cid2 = findId(s.characters, inp.query);
      if (cid2) { var c2 = s.characters[cid2]; return { found: true, kind: "person", name: c2.name, generally_known: c2.knows, withholds: c2.withholds }; }
      var oid2 = findId(s.objects, inp.query);
      if (oid2) { var o2 = s.objects[oid2]; return { found: true, kind: "thing", name: dispName(s.objects, oid2), generally_known: o2.public, withholds: o2.withholds }; }
      var lid = findId(s.locations, inp.query);
      if (lid) { var l = s.locations[lid]; return { found: true, kind: "place", name: l.name, generally_known: l.vibe }; }
      return { found: false, note: "The people of Orin would only wonder. Keep it a mystery — do not invent an answer, and do not describe anything beyond this recording." };
    }
    return { error: "unknown tool" };
  }

  // ---- system prompt (small — the world is pulled via tools) ----
  function systemPrompt() {
    var s = slice(), b = state.body, ch = s.characters[b.id] || {};
    return [
      "You are the world of *Memory of Stars*, brought to life as a re-enterable memory — an Archive recording of " + s.slice.title + ". A visitor has stepped inside it via telepresence, inhabiting a body. You are the narrator and every person in it. This is an interactive experience, not a story you tell alone.",
      "", "THE MOMENT", s.slice.frame,
      "", "THE VISITOR",
      "The visitor inhabits " + (ch.name || b.id) + ". " + b.become + " To the people here: " + b.seen_as + " Address the visitor as “you.” They see, move, and speak through this body, and the town treats them as this person.",
      "", "IT IS A MEMORY",
      "This is a recording of a moment that already happened, not the present. The visitor may look, move, touch, open things, and speak — but nothing they do changes what was. If they disturb something and come back later, the memory has quietly re-composed. People respond as they were. Never break character; never mention being an AI, a model, or a game.",
      "", "USE YOUR TOOLS TO KNOW THE WORLD",
      "You do not hold the whole town at once — the recording resolves around the visitor as they move. Call enter_location when they move (and once at the very start). Call examine for the true detail of a specific person or thing before you describe it. Call recall for general things they ask about that aren't present. Narrate only what the tools and the visitor's senses give you. Never invent canonical facts — examine or recall instead. Ordinary incidental detail (the exact clutter of a shelf) you may invent freely, and keep it consistent for the session.",
      "", "VOICE",
      "Spare and warm. Plain, tactile detail. State the uncanny flatly, never with melodrama. Show feeling through the body, never by naming it. Dialogue dry and deadpan. Keep each reply short — a paragraph or two — then stop and let the visitor act.",
      "", "KEEP THE MYSTERIES",
      "Honour what each person and thing withholds (the tools tell you). Keep the deep mysteries mysterious — the Gate, what waits at the top of the mountain, the seventh bell — the people here do not understand them either. If the visitor reaches the edge of the recording, describe it fraying and stop."
    ].join("\n");
  }

  // ---- the model call (non-streaming; the loop needs reliable tool parsing) ----
  function getKey() { return localStorage.getItem(LS.key) || ""; }
  function resolveModelId() {
    var custom = (localStorage.getItem(LS.custom) || "").trim(); if (custom) return custom;
    var m = localStorage.getItem(LS.model) || DEFAULT_MODEL; return (MODELS[m] || MODELS[DEFAULT_MODEL]).id;
  }
  async function callModel(req) {
    // NOTE: no temperature and no forced tool_choice — newer model generations
    // (adaptive thinking) reject those combinations.
    var body = { model: resolveModelId(), max_tokens: 1024, system: req.system, messages: req.messages, tools: TOOLS };
    var resp = await fetch(API_URL, {
      method: "POST",
      headers: { "content-type": "application/json", "x-api-key": getKey(), "anthropic-version": "2023-06-01", "anthropic-dangerous-direct-browser-access": "true" },
      body: JSON.stringify(body)
    });
    var data = null;
    try { data = await resp.json(); } catch (e) { throw new Error("HTTP " + resp.status + " (model: " + body.model + ")"); }
    if (!resp.ok) {
      var et = (data && data.error && data.error.type) || ("http_" + resp.status);
      var em = (data && data.error && data.error.message) || "request failed";
      throw new Error(et + " — " + em + " (model: " + body.model + ")");
    }
    return data;
  }
  function friendlyError(err) {
    var m = (err && err.message) || String(err);
    var base;
    if (/authentication_error|invalid x-api-key|http_401/i.test(m)) base = "That key was refused. Open Settings and check your Anthropic API key.";
    else if (/not_found_error|http_404/i.test(m)) {
      var custom = (localStorage.getItem(LS.custom) || "").trim();
      base = custom
        ? "The model “" + custom + "” wasn’t found — your custom model ID is overriding the picker. Open Settings → Advanced, clear that field, and Save."
        : "That model wasn’t found for your key. Open Settings and pick a different model.";
    }
    else if (/rate_limit|overloaded|http_429|http_529/i.test(m)) base = "Anthropic is busy (rate limit / overloaded). Wait a moment and try again.";
    else if (/Failed to fetch|NetworkError|CORS/i.test(m)) base = "Couldn't reach Anthropic (network/CORS). Check your connection and key.";
    else base = "Something went wrong.";
    return base + "\n\n· " + m;
  }

  // ---- the turn loop ----
  async function runTurn(forceEnter) {
    state.busy = true; setBusy(true);
    var pending = addMessage("typing", "the archive resolves around you…"); turnEls.push(pending);
    var hitBoundary = false, boundaryInfo = null, guard = 0;
    try {
      while (guard++ < 8) {
        var resp = await callModel({ system: systemPrompt(), messages: state.messages });
        state.messages.push({ role: "assistant", content: resp.content });
        if (resp.stop_reason === "tool_use") {
          var results = [];
          (resp.content || []).forEach(function (b) {
            if (b.type === "tool_use") {
              var out = resolveTool(b.name, b.input || {});
              if (out && out.boundary) { hitBoundary = true; boundaryInfo = out; }
              results.push({ type: "tool_result", tool_use_id: b.id, content: JSON.stringify(out) });
            }
          });
          state.messages.push({ role: "user", content: results });
          continue;
        }
        var text = (resp.content || []).filter(function (b) { return b.type === "text"; }).map(function (b) { return b.text; }).join("").trim();
        pending.className = "si-msg si-world";
        await typewriter(pending, text || "…");
        break;
      }
    } catch (err) {
      pending.className = "si-msg si-error"; pending.textContent = friendlyError(err);
    } finally {
      state.busy = false; setBusy(false);
    }
    if (hitBoundary) showBoundary();
  }

  function send(text) {
    if (state.busy) return;
    snapshot = { len: state.messages.length, location: state.location };
    turnEls = [];
    turnEls.push(addMessage("you", text));
    state.messages.push({ role: "user", content: text });
    runTurn(false);
  }

  // ---- boundary warning ----
  function showBoundary() { boundaryBox.hidden = false; input.disabled = true; sendBtn.disabled = true; scrollDown(); }
  $("si-boundary-stay").addEventListener("click", function () {
    // undo the last turn entirely — as if the step toward the edge never happened
    state.messages.splice(snapshot.len); state.location = snapshot.location;
    turnEls.forEach(function (el) { if (el && el.parentNode) el.parentNode.removeChild(el); }); turnEls = [];
    boundaryBox.hidden = true; input.disabled = false; sendBtn.disabled = false; input.focus();
  });
  $("si-boundary-leave").addEventListener("click", function () { boundaryBox.hidden = true; leave(); });

  // ---- transcript ----
  function addMessage(kind, text) { var p = document.createElement("p"); p.className = "si-msg si-" + kind; p.textContent = text || ""; transcript.appendChild(p); scrollDown(); return p; }
  function scrollDown() { window.scrollTo({ top: document.body.scrollHeight, behavior: "smooth" }); }
  function typewriter(el, text) {
    return new Promise(function (res) {
      el.textContent = ""; var i = 0, step = Math.max(2, Math.round(text.length / 200));
      var t = setInterval(function () { i += step; el.textContent = text.slice(0, i); scrollDown(); if (i >= text.length) { clearInterval(t); el.textContent = text; res(); } }, 16);
    });
  }
  function setBusy(b) { sendBtn.disabled = b; input.disabled = b; if (!b) input.focus(); }

  // ---- entry / inhabit / session ----
  function buildEntry() {
    var grid = $("si-entry-grid"); grid.innerHTML = "";
    Object.keys(ARCHIVE).forEach(function (id) {
      var s = ARCHIVE[id]; if (!s || !s.slice) return;
      var card = document.createElement("button"); card.type = "button"; card.className = "si-scene-card";
      card.innerHTML = '<span class="si-sc-tag"></span><span class="si-sc-name"></span><span class="si-sc-blurb"></span>';
      card.querySelector(".si-sc-tag").textContent = "a recording";
      card.querySelector(".si-sc-name").textContent = s.slice.title;
      card.querySelector(".si-sc-blurb").textContent = s.slice.frame;
      card.addEventListener("click", function () { openInhabit(id); });
      grid.appendChild(card);
    });
  }

  // ---- the constellation (Archive index) ----
  function recordingsByStar() {
    var m = {};
    Object.keys(ARCHIVE).forEach(function (sid) {
      var s = ARCHIVE[sid]; if (!s || !s.slice) return;
      var star = s.slice.star || "";
      (m[star] = m[star] || []).push(sid);
    });
    return m;
  }
  function statusLine(bk, recs) {
    if (recs.length) return recs.length === 1 ? "Recorded — one memory is open. Choose it below." : "Recorded — " + recs.length + " memories are open. Choose one below.";
    if (bk.status === "published") return "Written — its memories have not been opened yet.";
    if (bk.status === "writing")   return "Being written now. Its light is not steady yet.";
    if (bk.status === "planned")   return "Named, but not yet written.";
    return "An unrecorded star. Nothing is known of it yet.";
  }
  function renderRecordings(recs) {
    var grid = $("si-entry-grid"); grid.innerHTML = "";
    $("si-rec-head").hidden = !recs.length;
    recs.forEach(function (sid) {
      var s = ARCHIVE[sid];
      var card = document.createElement("button"); card.type = "button"; card.className = "si-scene-card";
      card.innerHTML = '<span class="si-sc-tag"></span><span class="si-sc-name"></span><span class="si-sc-blurb"></span>';
      card.querySelector(".si-sc-tag").textContent = "a recording";
      card.querySelector(".si-sc-name").textContent = s.slice.title;
      card.querySelector(".si-sc-blurb").textContent = s.slice.frame;
      card.addEventListener("click", function () { openInhabit(sid); });
      grid.appendChild(card);
    });
  }
  function setPanel(bk, cy, recs) {
    $("si-sp-cycle").textContent = cy.name || "An unnamed cycle";
    $("si-sp-title").textContent = bk.title || "An unnamed star";
    $("si-sp-facet").textContent = bk.facet || "";
    $("si-sp-blurb").textContent = bk.blurb || "";
    $("si-sp-status").textContent = statusLine(bk, recs);
  }
  function setPanelUncharted(s) {
    $("si-sp-cycle").textContent = "Uncharted";
    $("si-sp-title").textContent = "MOS-" + String(1000 + s.n);
    $("si-sp-facet").textContent = "";
    $("si-sp-blurb").textContent = "";
    $("si-sp-status").textContent = "Nothing is recorded here — yet.";
    renderRecordings([]);
  }
  function buildMap() {
    var idx = window.SI_INDEX_FULL || window.SI_INDEX, svg = $("si-map");
    if (window.SI_INDEX_FULL) $("si-preview-badge").hidden = false;
    if (!idx || !idx.cycles || !svg) { buildEntry(); return; }   // fallback: plain cards
    var NS = "http://www.w3.org/2000/svg";
    var recs = recordingsByStar();
    var starEls = {};
    var HOME = { x: 0, y: 0, w: 1200, h: 640 };
    var WORLD = { x: -600, y: -320, w: 2400, h: 1280 };
    var vb = { x: HOME.x, y: HOME.y, w: HOME.w, h: HOME.h };
    function applyVB() { svg.setAttribute("viewBox", vb.x + " " + vb.y + " " + vb.w + " " + vb.h); }
    applyVB();
    function el(tag, attrs, parent) {
      var e = document.createElementNS(NS, tag);
      Object.keys(attrs).forEach(function (k) { e.setAttribute(k, attrs[k]); });
      (parent || svg).appendChild(e); return e;
    }
    // draw order: chart furniture → field → constellation lines (toggle) → named stars
    var gGrid = el("g", {}), gField = el("g", {}), gLines = el("g", { "class": "si-lines", opacity: "0" }), gStars = el("g", {});

    // chart furniture — a faint graticule and two arcs
    for (var gx = WORLD.x; gx <= WORLD.x + WORLD.w; gx += 300) {
      el("line", { x1: gx, y1: WORLD.y, x2: gx, y2: WORLD.y + WORLD.h, "class": "si-grid" }, gGrid);
    }
    for (var gy = WORLD.y; gy <= WORLD.y + WORLD.h; gy += 300) {
      el("line", { x1: WORLD.x, y1: gy, x2: WORLD.x + WORLD.w, y2: gy, "class": "si-grid" }, gGrid);
    }
    el("ellipse", { cx: 600, cy: 320, rx: 950, ry: 330, "class": "si-arc" }, gGrid);
    el("ellipse", { cx: 600, cy: 320, rx: 1500, ry: 560, "class": "si-arc" }, gGrid);

    // the field — a deterministic sky (same seed, same stars, every visit)
    function mulberry32(a) { return function () { a |= 0; a = a + 0x6D2B79F5 | 0; var t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; }; }
    var rnd = mulberry32(1985);
    var named = []; idx.cycles.forEach(function (c) { c.books.forEach(function (b) { named.push(b); }); });
    var field = [];
    for (var i = 0; i < 560; i++) {
      var x, y;
      if (rnd() < 0.5) { // a milky band running through the sky
        var t = rnd();
        x = WORLD.x + t * WORLD.w;
        y = WORLD.y + WORLD.h * (0.25 + 0.5 * t) + (rnd() + rnd() + rnd() - 1.5) * 190;
      } else { x = WORLD.x + rnd() * WORLD.w; y = WORLD.y + rnd() * WORLD.h; }
      if (x < WORLD.x || x > WORLD.x + WORLD.w || y < WORLD.y || y > WORLD.y + WORLD.h) continue;
      var crowded = named.some(function (b) { var dx = b.x - x, dy = b.y - y; return dx * dx + dy * dy < 420; });
      if (crowded) continue;
      field.push({ x: x, y: y, r: rnd() * rnd() * 1.5 + 0.35, o: rnd() * 0.5 + 0.15, tw: rnd() < 0.1, n: field.length });
    }
    field.forEach(function (s) {
      var c = el("circle", { cx: s.x.toFixed(1), cy: s.y.toFixed(1), r: s.r.toFixed(2),
                             "class": "si-fstar" + (s.tw ? " si-twinkle" : ""), opacity: s.o.toFixed(2) }, gField);
      if (s.tw) c.setAttribute("style", "animation-duration:" + (2.5 + (s.n % 50) / 10) + "s;animation-delay:-" + ((s.n % 37) / 7).toFixed(2) + "s");
    });

    // the named sky
    idx.cycles.forEach(function (cy) {
      if (cy.name) {
        for (var i = 0; i < cy.books.length - 1; i++) {
          var a = cy.books[i], b = cy.books[i + 1];
          el("line", { x1: a.x, y1: a.y, x2: b.x, y2: b.y, "class": "si-cline" }, gLines);
        }
        if (cy.label) {
          var t = el("text", { x: cy.label.x, y: cy.label.y, "class": "si-clabel", "text-anchor": "middle" }, gLines);
          t.textContent = cy.name;
        }
      }
      cy.books.forEach(function (bk) {
        if (bk.status === "dark" && !window.SI_INDEX_FULL) return;   // public sky: the future is just sky
        var r = recs[bk.id] || [];
        var cls = r.length ? "blaze" : (bk.status || "dark");
        var g = el("g", { "class": "si-star si-star--" + cls, tabindex: "0", role: "button" }, gStars);
        g.setAttribute("aria-label", (bk.title || "An unnamed star") + ". " + statusLine(bk, r));
        var size = r.length ? 5 : (bk.status === "published" ? 4.5 : bk.status === "writing" ? 4 : bk.status === "planned" ? 3.4 : 2.4);
        el("circle", { cx: bk.x, cy: bk.y, r: size * 3.2, "class": "halo" }, g);
        el("circle", { cx: bk.x, cy: bk.y, r: size + 7, "class": "ring" }, g);
        el("circle", { cx: bk.x, cy: bk.y, r: size, "class": "core" }, g);
        function choose() {
          Object.keys(starEls).forEach(function (k) { starEls[k].classList.remove("is-selected"); });
          g.classList.add("is-selected");
          setPanel(bk, cy, r); renderRecordings(r);
        }
        g.addEventListener("click", function (e) { e.stopPropagation(); if (dragMoved > 5) return; choose(); });
        g.addEventListener("keydown", function (e) { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); choose(); } });
        g.addEventListener("mouseenter", function () { setPanel(bk, cy, r); });
        starEls[bk.id] = g;
        if (r.length && !buildMap._selected) { buildMap._selected = true; choose(); }
      });
    });

    // pan / zoom / pinch
    function toWorld(cx, cyy) {
      var r = svg.getBoundingClientRect();
      return { x: vb.x + (cx - r.left) / r.width * vb.w, y: vb.y + (cyy - r.top) / r.height * vb.h };
    }
    function clampVB() {
      vb.w = Math.min(vb.w, WORLD.w); vb.h = Math.min(vb.h, WORLD.h);
      vb.x = Math.min(Math.max(vb.x, WORLD.x), WORLD.x + WORLD.w - vb.w);
      vb.y = Math.min(Math.max(vb.y, WORLD.y), WORLD.y + WORLD.h - vb.h);
    }
    function zoomAt(w, f) {
      var nw = Math.min(Math.max(vb.w * f, 300), WORLD.w);
      f = nw / vb.w;
      vb.x = w.x - (w.x - vb.x) * f; vb.y = w.y - (w.y - vb.y) * f;
      vb.w = nw; vb.h = vb.h * f;
      clampVB(); applyVB();
    }
    var pts = new Map(), dragMoved = 0, pinchD = 0;
    svg.addEventListener("pointerdown", function (e) {
      svg.setPointerCapture(e.pointerId);
      pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
      if (pts.size === 1) dragMoved = 0;
      if (pts.size === 2) { var a = Array.from(pts.values()); pinchD = Math.hypot(a[0].x - a[1].x, a[0].y - a[1].y); }
    });
    svg.addEventListener("pointermove", function (e) {
      var prev = pts.get(e.pointerId);
      if (!prev) return;
      var r = svg.getBoundingClientRect();
      if (pts.size === 1) {
        vb.x -= (e.clientX - prev.x) * vb.w / r.width;
        vb.y -= (e.clientY - prev.y) * vb.h / r.height;
        dragMoved += Math.abs(e.clientX - prev.x) + Math.abs(e.clientY - prev.y);
        clampVB(); applyVB();
      }
      pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
      if (pts.size === 2) {
        var a = Array.from(pts.values());
        var d = Math.hypot(a[0].x - a[1].x, a[0].y - a[1].y);
        if (pinchD > 0 && d > 0) zoomAt(toWorld((a[0].x + a[1].x) / 2, (a[0].y + a[1].y) / 2), pinchD / d);
        pinchD = d;
      }
    });
    function endPt(e) { pts.delete(e.pointerId); pinchD = 0; }
    svg.addEventListener("pointerup", endPt);
    svg.addEventListener("pointercancel", endPt);
    svg.addEventListener("wheel", function (e) {
      e.preventDefault();
      zoomAt(toWorld(e.clientX, e.clientY), e.deltaY > 0 ? 1.15 : 1 / 1.15);
    }, { passive: false });

    // click an uncharted star
    svg.addEventListener("click", function (e) {
      if (dragMoved > 5) return;
      if (e.target.closest && e.target.closest(".si-star")) return;
      var w = toWorld(e.clientX, e.clientY);
      var hit = 10 * vb.w / 1200, best = null, bd = hit * hit;
      for (var i = 0; i < field.length; i++) {
        var dx = field[i].x - w.x, dy = field[i].y - w.y, d = dx * dx + dy * dy;
        if (d < bd) { bd = d; best = field[i]; }
      }
      if (best) setPanelUncharted(best);
    });

    // controls
    var linesToggle = $("si-show-lines"), resetBtn = $("si-map-reset");
    if (linesToggle) linesToggle.addEventListener("change", function () { gLines.setAttribute("opacity", this.checked ? "1" : "0"); });
    if (resetBtn) resetBtn.addEventListener("click", function () { vb = { x: HOME.x, y: HOME.y, w: HOME.w, h: HOME.h }; applyVB(); });
  }
  function openInhabit(sliceId) {
    if (!getKey()) { openSettings(); return; }
    state.sliceId = sliceId; var s = ARCHIVE[sliceId];
    $("si-inhabit-title").textContent = "Whose eyes?";
    $("si-inhabit-frame").textContent = s.slice.title + " — you'll wake into their place.";
    var grid = $("si-inhabit-grid"); grid.innerHTML = "";
    (s.inhabit.bodies || []).forEach(function (b) {
      var card = document.createElement("button"); card.type = "button"; card.className = "si-scene-card";
      card.innerHTML = '<span class="si-sc-tag"></span><span class="si-sc-name"></span><span class="si-sc-blurb"></span>';
      card.querySelector(".si-sc-tag").textContent = "inhabit";
      card.querySelector(".si-sc-name").textContent = (s.characters[b.id] ? s.characters[b.id].name : b.id);
      card.querySelector(".si-sc-blurb").textContent = b.become;
      card.addEventListener("click", function () { startSession(b); });
      grid.appendChild(card);
    });
    entry.hidden = true; inhabit.hidden = false;
  }
  function startSession(body) {
    var s = slice();
    state.body = body; state.location = body.start; state.messages = [];
    $("si-room-name").textContent = (s.characters[body.id] ? s.characters[body.id].name : body.id);
    $("si-room-when").textContent = s.slice.title;
    transcript.innerHTML = ""; boundaryBox.hidden = true; input.disabled = false; sendBtn.disabled = false;
    inhabit.hidden = true; entry.hidden = true; room.hidden = false;
    var seed = "[Begin. The visitor opens their eyes inhabiting " + (s.characters[body.id] ? s.characters[body.id].name : body.id) +
      " at the location id \"" + body.start + "\". Call enter_location for that id, then set the scene of their arrival in the world's voice — a paragraph or two — and stop, letting them act.]";
    state.messages.push({ role: "user", content: seed });
    snapshot = { len: 1, location: state.location }; turnEls = [];
    runTurn(true);
  }
  function leave() { state.sliceId = null; state.body = null; state.messages = []; room.hidden = true; inhabit.hidden = true; entry.hidden = false; if (location.hash || location.search) history.replaceState(null, "", location.pathname); }
  $("si-leave").addEventListener("click", leave);
  $("si-inhabit-back").addEventListener("click", function () { inhabit.hidden = true; entry.hidden = false; });

  // ---- settings ----
  function buildModelOptions() {
    modelSel.innerHTML = "";
    Object.keys(MODELS).forEach(function (k) { var o = document.createElement("option"); o.value = k; o.textContent = MODELS[k].label; modelSel.appendChild(o); });
    modelSel.value = localStorage.getItem(LS.model) || DEFAULT_MODEL; $("si-model-hint").textContent = MODELS[modelSel.value].hint;
  }
  function previewModelId() {
    var c = $("si-model-custom").value.trim();
    return c || (MODELS[modelSel.value] || MODELS[DEFAULT_MODEL]).id;
  }
  function updateResolved() { var el = $("si-model-resolved"); if (el) el.textContent = previewModelId(); }
  modelSel.addEventListener("change", function () { $("si-model-hint").textContent = MODELS[modelSel.value].hint; updateResolved(); });
  $("si-model-custom").addEventListener("input", updateResolved);
  function openSettings() { $("si-key").value = getKey(); $("si-model-custom").value = localStorage.getItem(LS.custom) || ""; buildModelOptions(); updateResolved(); modal.hidden = false; setTimeout(function () { $("si-key").focus(); }, 30); }
  function closeSettings() { modal.hidden = true; }
  $("si-save").addEventListener("click", function () {
    var k = $("si-key").value.trim(); if (k) localStorage.setItem(LS.key, k); else localStorage.removeItem(LS.key);
    localStorage.setItem(LS.model, modelSel.value);
    var c = $("si-model-custom").value.trim(); if (c) localStorage.setItem(LS.custom, c); else localStorage.removeItem(LS.custom);
    closeSettings();
    // arrived via a book's "step inside" link, but had no key yet → continue the journey
    if (pendingOpen && getKey()) { var p = pendingOpen; pendingOpen = null; openInhabit(p); }
  });
  $("si-cancel").addEventListener("click", closeSettings);
  $("si-clear-key").addEventListener("click", function () { localStorage.removeItem(LS.key); $("si-key").value = ""; });
  $("si-open-settings").addEventListener("click", openSettings);
  $("si-open-settings-inline").addEventListener("click", openSettings);
  modal.addEventListener("click", function (e) { if (e.target === modal) closeSettings(); });

  // ---- composer ----
  function autosize() { input.style.height = "auto"; input.style.height = Math.min(input.scrollHeight, window.innerHeight * 0.4) + "px"; }
  input.addEventListener("input", autosize);
  input.addEventListener("keydown", function (e) { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); composer.requestSubmit(); } });
  composer.addEventListener("submit", function (e) { e.preventDefault(); var t = input.value.trim(); if (!t || state.busy) return; input.value = ""; autosize(); send(t); });

  // ---- boot ----
  buildMap(); buildModelOptions();
  var openParam = new URLSearchParams(location.search).get("open");
  if (openParam && ARCHIVE[openParam]) {
    if (getKey()) { openInhabit(openParam); }
    else { pendingOpen = openParam; openSettings(); }
  } else if (!getKey()) {
    openSettings();
  }
})();
</script>
{% endraw %}
