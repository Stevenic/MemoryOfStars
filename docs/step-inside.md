---
layout: default
title: Step Inside
permalink: /step-inside/
description: Step into a recorded memory of Memory of Stars — inhabit someone who was there, and walk the world. Powered by your own Anthropic API key.
---
<script>
  /* The world DB + star index, injected at build time from docs/_data/ */
  window.SI_ARCHIVE = {{ site.data.archive | jsonify }};
  window.SI_STARS = {{ site.data.starfield | jsonify }};   /* the deterministic star catalog */
  window.SI_SYSTEMS = {                                     /* drill-down solar systems, by id */
    {% for sys in site.data %}{% if sys[1].system %}"{{ sys[1].system.id }}": {{ sys[1] | jsonify }},{% endif %}{% endfor %}
  };
  window.SI_BASEURL = "{{ site.baseurl }}";
</script>
{% raw %}
<section class="si-intro wrap">
  <p class="eyebrow">The Archive</p>
  <h1>The Memory of Stars</h1>
  <p class="lead">A sky of stars — far more than have names. The lit ones hold recorded
  moments you can step inside: inhabit someone who was there, wander the world, talk to
  the people. It's a memory — you can touch it, but you can't change what was. The rest
  of the sky is uncharted: stories not yet told. Between them lies everything else —
  pairs and triples, cinders, pulsars, the dark thing at the centre of it all, quasars
  burning from before this galaxy had a shape, and five objects nobody has accounted for.</p>
  <p class="si-note">Runs on <strong>your own Anthropic API key</strong> — the world is
  conjured live, so it uses your API credits. The key lives only in this browser.
  <button type="button" class="si-link" id="si-open-settings-inline">Settings</button></p>
</section>

<!-- ENTRY: the constellation (Archive index) -->
<section class="si-scenes wrap" id="si-entry">
  <p class="si-preview-badge" id="si-preview-badge" hidden>Roadmap preview — local only. Production shows these stars dark and unnamed.</p>
  <div class="si-map-wrap">
    <div class="si-map-ui">
      <button type="button" id="si-back-galaxy" hidden>◄ galaxy</button>
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
  <header class="si-room-head">
    <button type="button" class="si-back" id="si-leave">← step out</button>
    <div class="si-room-title">
      <span class="si-room-name" id="si-room-name"></span>
      <span class="si-room-when" id="si-room-when"></span>
    </div>
    <button type="button" class="si-gear" id="si-open-settings" title="Settings" aria-label="Settings">⚙</button>
  </header>

  <div class="si-transcript" id="si-transcript" aria-live="polite"></div>

  <!-- boundary warning -->
  <div class="si-boundary" id="si-boundary" hidden>
    <div class="si-boundary-inner">
      <p class="si-system"><strong>▚ edge of record.</strong> nothing is reconstructed beyond this point.</p>
      <div class="si-boundary-actions">
        <button type="button" class="si-btn-ghost" id="si-boundary-leave">Leave the Archive</button>
        <button type="button" class="si-btn-primary" id="si-boundary-stay">Stay (step back)</button>
      </div>
    </div>
  </div>

  <p class="si-hint">Try: <em>look around</em> · <em>who's here?</em> · <em>go to the market</em> · <em>ask her what she's afraid of</em> · <em>pick up the red bird</em></p>

  <form class="si-composer" id="si-composer">
    <textarea id="si-input" rows="1" placeholder="Look around, or say something…" autocomplete="off"></textarea>
    <button type="submit" id="si-send">Send</button>
  </form>
</section>

<!-- cross-temporal leak overlay: a ghost frame the Archive shouldn't have (filled at runtime) -->
<div id="si-leak" aria-hidden="true"></div>

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
.si-scene-card.si-locked { cursor: default; opacity: .5; }
.si-scene-card.si-locked:hover { transform: none; border-color: var(--border); }
.si-scene-card.si-locked .si-sc-tag { color: var(--muted); letter-spacing: .04em; }
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
#si-back-galaxy { background: rgba(10,14,26,.6); border: 1px solid var(--border); color: var(--muted); border-radius: 999px; padding: .3rem .8rem; font: inherit; font-size: .78rem; cursor: pointer; backdrop-filter: blur(4px); }
#si-back-galaxy:hover { border-color: var(--gold); color: var(--gold); }
#si-back-galaxy[hidden] { display: none; }
.si-starlabel { fill: var(--gold); font-size: 11px; letter-spacing: .04em; pointer-events: none; }
.si-planetlabel { fill: var(--muted); font-size: 10px; pointer-events: none; }
.si-orbit { fill: none; stroke: rgba(207,224,255,.13); stroke-width: 1; }
.si-belt { fill: rgba(207,224,255,.42); }
.si-sunglow { opacity: .3; }
.si-planet { cursor: pointer; }
.si-pbody { stroke: rgba(0,0,0,.35); stroke-width: .5; }
.si-planet:hover .si-pbody, .si-planet:focus .si-pbody { stroke: var(--gold); stroke-width: 1.6; }
.si-art { pointer-events: none; }
.si-grid { stroke: rgba(207,224,255,.045); stroke-width: 1; }
.si-arc { fill: none; stroke: rgba(233,196,106,.07); stroke-width: 1; }
.si-fstar { fill: #cfe0ff; }
.si-fstar { cursor: pointer; }

/* --- the rest of the universe: real objects, drawn as what they look like --- */
.si-neb { pointer-events: none; }
.si-speck { pointer-events: none; }
.si-snr { fill: none; stroke: rgba(150,220,255,.32); stroke-width: .7; pointer-events: none; }
.si-agn-core { fill: #efe4ff; }
.si-jet { stroke: rgba(198,168,255,.5); stroke-width: .7; }
.si-bh-disc { fill: #05070e; }
.si-bh-ring { fill: none; stroke: #ffbe72; stroke-width: .9; opacity: .85; }
.si-bh-quiet { fill: #05070e; stroke: rgba(207,224,255,.28); stroke-width: .5; }
.si-bh-jet { stroke: rgba(190,225,255,.45); stroke-width: .7; }
.si-stream { fill: none; stroke: rgba(255,200,140,.5); stroke-width: .55; }
.si-pulsar-core { fill: #eaf4ff; }
.si-pulsar-beam { fill: rgba(150,200,255,.10); }
/* The beam sweeps and the shell expands as a SYMBOL — a real pulsar's period is milliseconds
   and strobing it would be both unreadable and unkind. The true rate is in the panel. */
.si-spin { transform-origin: 0 0; animation: si-spin 9s linear infinite; }
@keyframes si-spin { to { transform: rotate(360deg); } }
.si-ping { fill: none; stroke: #9fd0ff; stroke-width: .6; transform-origin: 0 0; animation: si-ping 3.1s ease-out infinite; }
@keyframes si-ping { 0% { transform: scale(.25); opacity: .5; } 100% { transform: scale(3.6); opacity: 0; } }
/* Anomalies share the cold palette of the cross-temporal leak — straight lines and exact
   spacings, the two things nature never makes. Deliberately still: no animation, no glow. */
.si-anom { pointer-events: none; }
.si-anom-line { fill: none; stroke: #bfe6ff; stroke-width: .7; }
.si-anom-dot { fill: #dff1ff; }
.si-anom-void { fill: var(--bg); stroke: rgba(191,230,255,.38); stroke-width: .6; }
@media (prefers-reduced-motion: reduce) {
  .si-spin, .si-ping { animation: none; }
  .si-ping { opacity: .22; }
}

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

.si-room {
  position: fixed; top: 0; left: 0; right: 0;
  height: 100vh; height: 100dvh; z-index: 40;
  display: flex; flex-direction: column; align-items: center;
  padding: 0 1.25rem;
  background: radial-gradient(1000px 520px at 70% -10%, rgba(122,162,255,.10), transparent 60%), var(--bg);
}
.si-room[hidden] { display: none; }   /* author display:flex would otherwise defeat the hidden attribute */
.si-room > * { width: 100%; max-width: 44rem; }
.si-room-head { flex: 0 0 auto; display: flex; align-items: center; gap: 1rem; padding: 1rem 0; border-bottom: 1px solid var(--border); }
.si-room-title { flex: 1; text-align: center; display: flex; flex-direction: column; }
.si-room-name { font-family: "Iowan Old Style", Palatino, Georgia, serif; font-size: 1.15rem; color: var(--text); }
.si-room-when { color: var(--gold); font-size: .66rem; letter-spacing: .14em; text-transform: uppercase; }
.si-back, .si-gear { background: none; border: 1px solid var(--border); color: var(--muted); border-radius: 999px; cursor: pointer; font: inherit; }
.si-back { padding: .35rem .8rem; font-size: .85rem; }
.si-gear { width: 2.1rem; height: 2.1rem; font-size: 1rem; }
.si-back:hover, .si-gear:hover { border-color: var(--gold); color: var(--gold); }

.si-transcript { flex: 1 1 auto; min-height: 0; overflow-y: auto; overscroll-behavior: contain; font-family: "Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif; font-size: 1.18rem; line-height: 1.8; color: #eef1fb; padding: 1.5rem 0; }
.si-msg { margin: 0 0 1.3rem; white-space: pre-wrap; }
.si-you { color: var(--gold-soft); }
.si-you::before { content: "You: "; color: var(--gold); font-variant-caps: small-caps; }
.si-typing { color: var(--muted); font-style: italic; display: flex; align-items: center; gap: .4rem; }
.si-dots { display: inline-flex; gap: .3rem; flex: 0 0 auto; }
.si-dots i { width: .42rem; height: .42rem; border-radius: 50%; background: var(--gold); display: inline-block; opacity: .25; animation: si-blink 1.3s infinite ease-in-out; }
.si-dots i:nth-child(2) { animation-delay: .18s; }
.si-dots i:nth-child(3) { animation-delay: .36s; }
@keyframes si-blink { 0%, 75%, 100% { opacity: .2; } 38% { opacity: 1; } }

/* System / machine voice — the Archive itself speaking (boot screen, boundary). */
.si-system {
  font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace;
  font-size: .82rem; letter-spacing: .03em; line-height: 1.6;
  color: var(--gold); opacity: .85; margin: 0 0 .55rem; white-space: pre-wrap;
}
@media (prefers-reduced-motion: reduce) { .si-dots i { animation-duration: 2s; } }
.si-error { color: #ffb4a2; font-size: .95rem; border-left: 3px solid #ffb4a2; padding-left: .8rem; }

/* --- the flaky Archive: it misfires like old, failing tech, not a tasteful patina --- */
.si-glitch-flick { animation: si-flick 200ms steps(2, end) 1; }
@keyframes si-flick { 0%, 100% { opacity: 1; } 45% { opacity: .32; } 70% { opacity: .92; } }
.si-desync { animation: si-desync 160ms steps(2, end) 1; }
@keyframes si-desync {
  0% { transform: translateX(0); }
  30% { transform: translateX(-2px); filter: hue-rotate(6deg) saturate(1.3); }
  60% { transform: translateX(3px); }
  100% { transform: translateX(0); }
}
/* Rare cross-temporal "leak": a ghost megastructure flashes across the screen, gone
   before you're sure you saw it. Single low-contrast flash (photosensitivity-safe). */
#si-leak { position: fixed; inset: 0; z-index: 60; display: grid; place-items: center; pointer-events: none; opacity: 0; mix-blend-mode: screen; }
#si-leak svg { width: min(58vmin, 380px); height: auto; }
#si-leak svg .w { fill: none; stroke: #bfe6ff; stroke-width: .7; stroke-linejoin: round; }
#si-leak svg .star { fill: #eaf6ff; }
#si-leak svg .glow { fill: #bfe6ff; opacity: .18; }
#si-leak.si-leak-flash { animation: si-leak 620ms ease-out 1; }
@keyframes si-leak { 0% { opacity: 0; } 14% { opacity: .26; } 34% { opacity: .05; } 52% { opacity: .16; } 100% { opacity: 0; } }
@media (prefers-reduced-motion: reduce) {
  .si-glitch-flick, .si-desync, #si-leak.si-leak-flash { animation: none; }
  #si-leak { opacity: 0 !important; }
}

.si-composer { flex: 0 0 auto; display: flex; gap: .6rem; align-items: flex-end; padding: .8rem 0 1.1rem; border-top: 1px solid var(--border); }
.si-composer textarea { flex: 1; resize: none; background: var(--panel); color: var(--text); border: 1px solid var(--border); border-radius: 12px; padding: .7rem .9rem; font: inherit; font-size: 1rem; line-height: 1.5; max-height: 40vh; }
.si-composer textarea:focus { outline: none; border-color: var(--gold); }
#si-send { background: var(--gold); color: #201803; border: none; border-radius: 999px; padding: .7rem 1.3rem; font-weight: 600; cursor: pointer; font: inherit; font-size: .95rem; }
#si-send:disabled { opacity: .5; cursor: default; }
.si-hint { flex: 0 0 auto; color: var(--muted); font-size: .8rem; margin: .35rem 0 0; }
.si-hint em { color: var(--star); font-style: normal; }

.si-boundary { flex: 0 0 auto; margin: 0 0 .5rem; }
.si-boundary-inner { background: linear-gradient(180deg, rgba(20,27,51,.96), rgba(26,34,66,.98)); border: 1px solid var(--gold); border-radius: var(--radius); padding: 1.1rem 1.3rem; backdrop-filter: blur(6px); }
.si-boundary-inner p { margin: 0 0 .8rem; }
.si-boundary-inner .si-system { margin: 0 0 .8rem; opacity: 1; }
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

  var state = { sliceId: null, memory: null, body: null, location: null, messages: [], busy: false };
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
  // Merge the current memory's per-location overrides onto the base geography.
  function locState(id) {
    var s = slice(), base = s.locations[id]; if (!base) return null;
    var ov = state.memory && state.memory.overrides && state.memory.overrides[id];
    return {
      name: base.name,
      vibe: (ov && ov.vibe) || base.vibe,
      present: (ov && ov.present) || base.present || [],
      objects: (ov && ov.objects) || base.objects || [],
      exits: base.exits || []
    };
  }
  function memoriesFor(sliceId) { var s = ARCHIVE[sliceId]; return (s && s.memories) || []; }
  // Read-to-unlock: a memory opens once you've read a chapter that surfaces it. The reader
  // writes mos_read on ~80% scroll (keyed book-NN-chapter-N, normalized across versions).
  function readSet() { try { return JSON.parse(localStorage.getItem("mos_read") || "{}"); } catch (e) { return {}; } }
  function isRead(star, ck) { return !!readSet()[star + "-" + ck]; }
  function markRead(star, ck) { try { var r = readSet(); r[star + "-" + ck] = true; localStorage.setItem("mos_read", JSON.stringify(r)); } catch (e) {} }
  function memUnlocked(star, mem, all) {
    var chs = mem.chapters || [];
    if (chs.length) return chs.some(function (ck) { return isRead(star, ck); });
    // chapterless memory (backstory / sky-only): opens once every chapter the book's
    // memories reference has been read — i.e. you've finished the book.
    var refs = {}; (all || []).forEach(function (m) { (m.chapters || []).forEach(function (ck) { refs[ck] = true; }); });
    var keys = Object.keys(refs);
    return keys.length > 0 && keys.every(function (ck) { return isRead(star, ck); });
  }
  function memoriesForStar(starId) {
    var out = [];
    Object.keys(ARCHIVE).forEach(function (sid) {
      var s = ARCHIVE[sid]; if (!s || !s.slice || s.slice.star !== starId) return;
      var all = s.memories || [];
      all.forEach(function (m) { out.push({ sliceId: sid, mem: m, unlocked: memUnlocked(starId, m, all) }); });
    });
    return out;
  }
  function memoriesForChapter(sliceId, chapterKey) {
    return memoriesFor(sliceId).filter(function (m) { return (m.chapters || []).indexOf(chapterKey) >= 0; })
      .map(function (m) { return { sliceId: sliceId, mem: m }; });
  }

  // ---- tool resolution (local, against the world DB) ----
  function resolveTool(name, inp) {
    var s = slice();
    if (name === "enter_location") {
      var id = inp.location_id, loc = locState(id);
      if (loc) {
        state.location = id;
        return { location: {
          id: id, name: loc.name, vibe: loc.vibe,
          here: (loc.present || []).filter(function (c) { return c !== state.body; }).map(function (c) { return charRec(s, c); }).filter(Boolean),
          things: (loc.objects || []).map(function (o) { return { id: o, name: dispName(s.objects, o) }; }),
          ways_out: (loc.exits || []).map(function (e) { return { to: e.to, name: (s.locations[e.to] ? s.locations[e.to].name : objName(e.to)), note: e.note, boundary: !!e.boundary }; })
        } };
      }
      var edges = (s.boundaries && s.boundaries.edges) || {};
      if (edges[id]) return { boundary: true, edge: id, note: edges[id], fraying: s.boundaries.fraying };
      return { error: "There is no way to reach '" + id + "' from here." };
    }
    if (name === "examine") {
      var loc2 = locState(state.location) || {};
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
    var s = slice(), m = state.memory || {}, ch = s.characters[state.body] || {}, per = (s.personas || {})[state.body] || {};
    return [
      "You are the world of *Memory of Stars*, brought to life as a re-enterable memory — an Archive recording of " + s.slice.title + ". A visitor has stepped inside it via telepresence, inhabiting a body. You are the narrator and every person in it. This is an interactive experience, not a story you tell alone.",
      "", "THE MOMENT",
      (m.title ? m.title + (m.when ? " — " + m.when : "") + ". " : "") + (m.frame || s.slice.frame),
      "", "THE VISITOR",
      "The visitor inhabits " + (ch.name || state.body) + ". " + (per.become || "") + " To the people here: " + (per.seen_as || "") + " Address the visitor as “you.” They see, move, and speak through this body, and the town treats them as this person.",
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
  // Core generator: runs the model tool-loop against state.messages and returns the final
  // narration + boundary info. No presentation — callers own the typing indicator.
  async function generate() {
    var hitBoundary = false, boundaryInfo = null, guard = 0, text = "";
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
      text = (resp.content || []).filter(function (b) { return b.type === "text"; }).map(function (b) { return b.text; }).join("").trim();
      break;
    }
    return { text: text, hitBoundary: hitBoundary, boundaryInfo: boundaryInfo };
  }

  async function reveal(text) { var el = addMessage("world", ""); turnEls.push(el); await typewriter(el, text || "…"); }

  // A normal turn: the dot indicator on its own line, then the reply as a fresh line.
  async function runTurn() {
    state.busy = true; setBusy(true);
    var dots = addTyping(); turnEls.push(dots);
    try {
      var r = await generate();
      if (dots.parentNode) dots.parentNode.removeChild(dots);
      await reveal(r.text);
      if (r.hitBoundary) showBoundary();
    } catch (err) {
      dots.className = "si-msg si-error"; dots.textContent = friendlyError(err);
    } finally { state.busy = false; setBusy(false); }
  }

  // Session boot: stream a few system lines to mask the first query while the model
  // reconstructs the opening in parallel, then reveal the scene.
  function bootLines() {
    var s = slice(), m = state.memory || {}, name = (s.characters[state.body] ? s.characters[state.body].name : state.body);
    return [
      "▚ THE ARCHIVE · session opening",
      "locating memory · " + (m.title || s.slice.title),
      "reconstructing volume …",
      "integrity 84% · some detail has decayed. this is expected.",
      "inhabiting · " + name
    ];
  }
  async function runOpening() {
    state.busy = true; setBusy(true);
    var gen = generate(); gen.catch(function () {});   // fire in parallel; surfaced at await below
    try {
      var lines = bootLines();
      for (var i = 0; i < lines.length; i++) {
        var d = addTyping(); turnEls.push(d);
        await sleep(240 + Math.floor(Math.random() * 260));
        if (d.parentNode) d.parentNode.removeChild(d);
        var sys = addMessage("system", ""); turnEls.push(sys);
        await typewriter(sys, lines[i]);
        await sleep(150);
      }
      var d2 = addTyping(); turnEls.push(d2);          // wait for the world to finish resolving
      var r = await gen;
      if (d2.parentNode) d2.parentNode.removeChild(d2);
      await reveal(r.text);
      if (r.hitBoundary) showBoundary();
    } catch (err) {
      turnEls.push(addMessage("error", friendlyError(err)));
    } finally { state.busy = false; setBusy(false); }
  }

  function send(text) {
    if (state.busy) return;
    snapshot = { len: state.messages.length, location: state.location };
    turnEls = [];
    turnEls.push(addMessage("you", text));
    state.messages.push({ role: "user", content: text });
    runTurn();
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
  function addTyping() {
    var p = document.createElement("p"); p.className = "si-msg si-typing";
    var dots = document.createElement("span"); dots.className = "si-dots"; dots.innerHTML = "<i></i><i></i><i></i>";
    p.appendChild(dots);
    transcript.appendChild(p); scrollDown(); return p;
  }
  function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms); }); }
  function scrollDown() { transcript.scrollTop = transcript.scrollHeight; }
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
  function statusLine(bk, mems) {
    var total = (mems || []).length, open = (mems || []).filter(function (x) { return x.unlocked; }).length;
    if (total) {
      if (open === 0) return total + (total === 1 ? " memory" : " memories") + " here — read the book to open " + (total === 1 ? "it" : "them") + ".";
      if (open >= total) return "All " + total + " memories open. Step into one below.";
      return open + " of " + total + " memories open — read on to reach the rest.";
    }
    if (bk.status === "published") return "Written — its memories have not been opened yet.";
    if (bk.status === "writing")   return "Being written now. Its light is not steady yet.";
    if (bk.status === "planned")   return "Named, but not yet written.";
    return "An unrecorded star. Nothing is known of it yet.";
  }
  function renderMemories(list) {
    var grid = $("si-entry-grid"); grid.innerHTML = "";
    $("si-rec-head").hidden = !list.length;
    list.slice().sort(function (a, b) { return (b.unlocked ? 1 : 0) - (a.unlocked ? 1 : 0); }).forEach(function (it) {
      var m = it.mem, ok = it.unlocked;
      var card = document.createElement(ok ? "button" : "div");
      if (ok) card.type = "button";
      card.className = "si-scene-card" + (ok ? "" : " si-locked");
      card.innerHTML = '<span class="si-sc-tag"></span><span class="si-sc-name"></span><span class="si-sc-blurb"></span>';
      if (ok) {
        card.querySelector(".si-sc-tag").textContent = m.when || "a memory";
        card.querySelector(".si-sc-name").textContent = m.title;
        card.querySelector(".si-sc-blurb").textContent = m.frame || "";
        card.addEventListener("click", function () { openInhabit(it.sliceId, m.id); });
      } else {
        card.querySelector(".si-sc-tag").textContent = "🔒 sealed";
        card.querySelector(".si-sc-name").textContent = "An unread memory";
        card.querySelector(".si-sc-blurb").textContent = "Read the chapter it belongs to, and it opens here.";
      }
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
    renderMemories([]);
  }

  // ============================ THE COSMOS ==============================
  // A real starfield you browse; reading lights the story-stars; a lit star drills
  // into its solar system (accurate-ish orbits). Replaces the old constellation map.
  var STARS = window.SI_STARS || { bounds: { w: 2000, h: 1200 }, stars: [] };
  var SYSTEMS = window.SI_SYSTEMS || {};
  var CLS_COLOR = { O: "#9db4ff", B: "#b3ccff", A: "#dce6ff", F: "#f6f4ff", G: "#fff2cf", K: "#ffcf9a", M: "#ff9d78" };
  var NS2 = "http://www.w3.org/2000/svg";
  var cosmos = { view: null, panzoom: null };

  function bookTouched(bookId) { var r = readSet(); return Object.keys(r).some(function (k) { return k.indexOf(bookId + "-") === 0; }); }
  function starLit(s) { return !!(s.refs && s.refs.length && s.refs.some(function (b) { return bookTouched(b); })); }
  // --- Progressive UX disclosure: a feature appears only when the story makes it relevant.
  // The GALAXY/starfield unlocks once >=2 systems are charted (Cycle 2 goes interstellar);
  // until then a reader sees only their home system — the universe IS one system, so far.
  // (Future gates, same pattern, each keyed to the book that reveals it: the timeline
  // scrubber, the mesh/megastructure overlay, memory/star filters.)
  function chartedStars() { return (STARS.stars || []).filter(function (s) { return s.name && s.system && starLit(s); }); }
  function galaxyUnlocked() { return chartedStars().length >= 2; }
  function homeSystem() {
    for (var i = 0; i < (STARS.stars || []).length; i++) { var s = STARS.stars[i]; if (s.name && s.system && SYSTEMS[s.system]) return s.system; }
    return null;
  }
  function showDefault() {
    if (galaxyUnlocked()) { showGalaxy(); return; }
    var hs = homeSystem();
    if (hs) showSystem(hs); else showGalaxy();
  }
  function svgEl(svg, tag, attrs, parent) { var e = document.createElementNS(NS2, tag); Object.keys(attrs).forEach(function (k) { e.setAttribute(k, attrs[k]); }); (parent || svg).appendChild(e); return e; }
  function freshSvg() { var old = $("si-map"); var n = old.cloneNode(false); old.parentNode.replaceChild(n, old); return n; }
  function panZoom(svg, world, home) {
    var vb = { x: home.x, y: home.y, w: home.w, h: home.h };
    function apply() { svg.setAttribute("viewBox", vb.x + " " + vb.y + " " + vb.w + " " + vb.h); }
    function clamp() { vb.w = Math.min(vb.w, world.w); vb.h = Math.min(vb.h, world.h); vb.x = Math.min(Math.max(vb.x, world.x), world.x + world.w - vb.w); vb.y = Math.min(Math.max(vb.y, world.y), world.y + world.h - vb.h); }
    function toWorld(cx, cy) { var r = svg.getBoundingClientRect(); return { x: vb.x + (cx - r.left) / r.width * vb.w, y: vb.y + (cy - r.top) / r.height * vb.h }; }
    function zoomAt(w, f) { var nw = Math.min(Math.max(vb.w * f, world.w * 0.05), world.w); f = nw / vb.w; vb.x = w.x - (w.x - vb.x) * f; vb.y = w.y - (w.y - vb.y) * f; vb.w = nw; vb.h *= f; clamp(); apply(); }
    var pts = new Map(), moved = 0, pinch = 0;
    svg.addEventListener("pointerdown", function (e) { svg.setPointerCapture(e.pointerId); pts.set(e.pointerId, { x: e.clientX, y: e.clientY }); if (pts.size === 1) moved = 0; if (pts.size === 2) { var a = Array.from(pts.values()); pinch = Math.hypot(a[0].x - a[1].x, a[0].y - a[1].y); } });
    svg.addEventListener("pointermove", function (e) { var p = pts.get(e.pointerId); if (!p) return; var r = svg.getBoundingClientRect(); if (pts.size === 1) { vb.x -= (e.clientX - p.x) * vb.w / r.width; vb.y -= (e.clientY - p.y) * vb.h / r.height; moved += Math.abs(e.clientX - p.x) + Math.abs(e.clientY - p.y); clamp(); apply(); } pts.set(e.pointerId, { x: e.clientX, y: e.clientY }); if (pts.size === 2) { var a = Array.from(pts.values()); var d = Math.hypot(a[0].x - a[1].x, a[0].y - a[1].y); if (pinch > 0 && d > 0) zoomAt(toWorld((a[0].x + a[1].x) / 2, (a[0].y + a[1].y) / 2), pinch / d); pinch = d; } });
    function pe(e) { pts.delete(e.pointerId); pinch = 0; }
    svg.addEventListener("pointerup", pe); svg.addEventListener("pointercancel", pe);
    svg.addEventListener("wheel", function (e) { e.preventDefault(); zoomAt(toWorld(e.clientX, e.clientY), e.deltaY > 0 ? 1.15 : 1 / 1.15); }, { passive: false });
    apply();
    return { toWorld: toWorld, moved: function () { return moved; }, span: function () { return vb.w; },
             reset: function () { vb = { x: home.x, y: home.y, w: home.w, h: home.h }; apply(); } };
  }
  function setSky(sub, title, blurb, status) {
    $("si-sp-cycle").textContent = sub || ""; $("si-sp-title").textContent = title || "";
    $("si-sp-facet").textContent = ""; $("si-sp-blurb").textContent = blurb || ""; $("si-sp-status").textContent = status || "";
  }
  function clearMemPanel() { $("si-rec-head").hidden = true; $("si-rec-head").textContent = "Open a memory"; $("si-entry-grid").innerHTML = ""; }

  // --- what the catalogue holds, said plainly. Observation only: the Archive is a record
  // of what was seen, and it does not explain the things it cannot explain. ---
  var CLS_DESC = {
    O: "Blue, enormous, and violent — it will be gone in a few million years.",
    B: "Blue-white and short-lived.",
    A: "White and hot, still young.",
    F: "Yellow-white, a little brighter than the sun.",
    G: "A yellow star — near enough the sun's twin.",
    K: "An orange dwarf: cooler than the sun, and steady for far longer.",
    M: "A red dwarf — small, dim, and patient. Most of the sky is these."
  };
  function multiLine(n) {
    if (n === 2) return "Two stars, not one; they go round each other. Most stars do.";
    if (n === 3) return "Three — a close pair, and a third far out. Triples are only stable that way.";
    return "Four, as two pairs orbiting each other at a distance.";
  }
  function spinLine(p) {
    if (p < 100) return Math.round(1000 / p) + " times a second";
    if (p < 2000) return "once every " + (p / 1000).toFixed(2) + " seconds";
    return "once every " + (p / 1000).toFixed(1) + " seconds";
  }
  // A white dwarf's colour IS its age: blue-white out of the furnace, dull orange after
  // ten billion years of cooling with nothing left to burn.
  function wdColor(t) {
    if (!t || t >= 20000) return "#cfe0ff";
    if (t >= 12000) return "#e6eeff";
    if (t >= 8000) return "#fff6ea";
    if (t >= 6000) return "#ffe6c2";
    return "#ffcb9b";
  }
  function describeStar(s) {
    var comps = (s.comp || []).length, n = comps + 1;
    if (s.kind === "smbh") return ["the centre", s.id,
      "Four million suns of nothing, at the exact middle of everything. It is not feeding, so " +
      "there is nothing to see — you find it by the handful of stars whipping round it on orbits " +
      "measured in decades.", "Every star on this chart is falling around this point, and has been for a long time."];
    if (s.kind === "bh") {
      var m = s.m_sol + " solar masses";
      if (s.mode === "quiet") return ["a black hole", s.id,
        "An ordinary star, going round nothing at all. Nothing is there to see; the star's own " +
        "swinging is the whole of the evidence.", m + ", found by arithmetic."];
      var b = "A star beside it is coming apart in a thread, and where the thread ends the sky is " +
              "bright in X-rays and dark in every other light.";
      if (s.mode === "microquasar") b += " Two jets leave it in opposite directions at nearly the speed of light, and do not stop.";
      return ["a black hole", s.id, b, m + " · the companion has years, not aeons."];
    }
    if (s.kind === "pulsar") {
      var turns = spinLine(s.p_ms);
      if (s.sub === "millisecond") return ["a pulsar", s.id,
        "A dead star the size of a city, turning " + turns + " — spun back up to that speed by the " +
        "companion it stripped. The companion is still there: a white dwarf, going round.",
        "Recycled · " + s.p_ms + " ms · the beam only reaches us because it happens to point this way."];
      if (s.sub === "magnetar") return ["a pulsar", s.id,
        "The slow, violent kind. It turns " + turns + ", carries the strongest magnetic field known " +
        "to exist, and flares in X-rays for a season before going quiet again for decades.",
        "Magnetar · " + (s.p_ms / 1000).toFixed(1) + " s · only a handful have ever been catalogued."];
      return ["a pulsar", s.id,
        "What a supernova left behind: a star's worth of matter packed into a mountain, turning " +
        turns + " and sweeping a beam past this sky each time.",
        "Young · " + s.p_ms + " ms · slowing, measurably, every year."];
    }
    if (s.kind === "wd") return ["a white dwarf", s.id,
      "What a star like the sun ends as — a cinder the size of a world, holding a sun's worth of " +
      "mass and cooling with nothing left to burn.",
      (s.t_k ? s.t_k.toLocaleString() + " K and falling. " : "") + "It will still be here when the galaxy is not."];
    var blurb = CLS_DESC[s.cls] || "";
    if (comps) blurb += " " + multiLine(n);
    return ["uncharted", s.id || "an unnamed star", blurb,
      "Class " + s.cls + " · magnitude " + s.mag + (comps ? " · " + n + " suns" : "") + " · nothing is recorded here yet."];
  }
  function describeDeep(d) {
    var K = {
      globular: ["a globular cluster",
        "Several hundred thousand stars in a ball, bound to each other since before the disk of this " +
        "galaxy finished forming. Nothing new has been born here in ten billion years.",
        (d.age_gyr || "") + " billion years old · " + (d.n || "") + " of its brightest resolved."],
      open: ["an open cluster",
        "Stars born together and already drifting apart — a few hundred million years from now the " +
        "galaxy's tides will have pulled this loose into the general crowd, and nobody will be able " +
        "to tell they were siblings.",
        (d.age_myr || "") + " million years old · " + (d.n || "") + " members."],
      emission: ["an emission nebula",
        "Hydrogen lit from the inside by the hot young stars it has just finished making. The crimson " +
        "is the gas itself, glowing at one exact wavelength.",
        "About " + (d.ly || "") + " light-years across · still forming stars."],
      reflection: ["a reflection nebula",
        "Dust with no light of its own, scattering a neighbour's — and blue for exactly the same " +
        "reason a daytime sky is.", "Cold, and only visible because something bright stands nearby."],
      dark: ["a dark nebula",
        "Cold dust, dense enough to hide everything behind it. You do not see it; you see the hole " +
        "where the stars stop.", "Inside, out of the light, the next generation is condensing."],
      planetary: ["a planetary nebula",
        "A sun-like star's outer atmosphere, shrugged off and drifting, lit from within by the white " +
        "dwarf left in the middle. The teal is oxygen.",
        (d.age_kyr || "") + ",000 years old · it will have dispersed within twenty thousand more."],
      snr: ["a supernova remnant",
        "The shell of a star that died, still going outward at thousands of kilometres a second and " +
        "ploughing everything it meets into filaments.",
        (d.age_kyr || "") + ",000 years since the light of it arrived."],
      dwarf: ["a satellite galaxy",
        "A small galaxy in orbit around this one, and slowly coming apart in the process — a trail of " +
        "its stars is already strung out behind it.",
        (d.kly || "") + ",000 light-years away · outside the disk entirely."]
    };
    var k = K[d.kind] || ["deep sky", "", ""];
    return [k[0], d.id, k[1], k[2]];
  }
  function describeAgn(a) {
    var far = a.gyr + " billion years ago";
    if (a.kind === "blazar") return ["a blazar", a.id,
      "The core of a distant galaxy with one of its jets aimed straight down this line of sight. It " +
      "brightens and dims over hours, and what looks like a flicker is a thing the size of a solar " +
      "system changing its mind.",
      "z = " + a.z + " · the light left " + far + " · magnitude " + a.mag + "."];
    return ["a quasar", a.id,
      "It looks like a star. It is the centre of a galaxy, outshining every one of its own hundred " +
      "billion suns, powered by what is falling into the black hole at the middle of it. The light " +
      "reaching this catalogue left " + far + " — before this galaxy had a shape.",
      "z = " + a.z + " · magnitude " + a.mag + (a.mag > 19 ? " · at the edge of what still resolves." : ".")];
  }
  function describeAnom(a) {
    return ["unresolved", a.id, a.observed,
      "Catalogued, confirmed, and unexplained. The Archive has no entry for what this is."];
  }

  // deterministic speckle — the same cluster, grain for grain, on every visit
  function mulberry32(a) {
    return function () {
      a |= 0; a = a + 0x6D2B79F5 | 0;
      var t = Math.imul(a ^ a >>> 15, 1 | a);
      t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
      return ((t ^ t >>> 14) >>> 0) / 4294967296;
    };
  }
  function skyDefs(svg) {
    var defs = svgEl(svg, "defs", {});
    function grad(id, stops) {
      var g = svgEl(svg, "radialGradient", { id: id }, defs);
      stops.forEach(function (s) { svgEl(svg, "stop", { offset: s[0], "stop-color": s[1], "stop-opacity": s[2] }, g); });
    }
    grad("si-g-emission",   [["0%", "#ff6a86", ".30"], ["45%", "#c2365f", ".15"], ["100%", "#7a1f4a", "0"]]);
    grad("si-g-reflection", [["0%", "#8fb6ff", ".26"], ["55%", "#4f6fc4", ".11"], ["100%", "#2a3a7a", "0"]]);
    grad("si-g-planetary",  [["0%", "#a8ffe8", ".38"], ["50%", "#2fb8a8", ".18"], ["100%", "#12595c", "0"]]);
    grad("si-g-cluster",    [["0%", "#dfe8ff", ".20"], ["60%", "#8fa6dd", ".06"], ["100%", "#5a6fae", "0"]]);
    grad("si-g-dwarf",      [["0%", "#e6ddff", ".17"], ["55%", "#8f86c8", ".07"], ["100%", "#4a4478", "0"]]);
    grad("si-g-core",       [["0%", "#ffd9a0", ".38"], ["45%", "#c96a3a", ".14"], ["100%", "#3a1a10", "0"]]);
    grad("si-g-agn",        [["0%", "#e9d6ff", ".50"], ["55%", "#8f6cff", ".16"], ["100%", "#3a2a7a", "0"]]);
    grad("si-g-milk",       [["0%", "#b9c9f2", ".085"], ["60%", "#8496d0", ".03"], ["100%", "#5a6fae", "0"]]);
    // dust: the sky's own colour, painted back over the stars, feathered because real dust
    // has no edge — it just gets thinner until you can see through it (matches --bg)
    grad("si-g-dust",       [["0%", "#0a0e1a", ".82"], ["55%", "#0a0e1a", ".62"], ["100%", "#0a0e1a", "0"]]);
    grad("si-g-anom",       [["0%", "#bfe6ff", ".10"], ["55%", "#8fc4e8", ".035"], ["100%", "#4a7a9a", "0"]]);
  }
  // The band is the galaxy seen edge-on from inside it — unresolved starlight, too faint and
  // too crowded to separate. Laid down first, behind everything, along the same line the
  // generator scatters the disk population on.
  function milkyWay(svg, parent, W, H) {
    var a = Math.atan2(H * 0.52, W) * 57.2958;
    for (var i = 0; i <= 10; i++) {
      var t = i / 10, x = t * W, y = H * (0.24 + 0.52 * t);
      svgEl(svg, "ellipse", { cx: x.toFixed(0), cy: y.toFixed(0), rx: 300, ry: 108,
                              transform: "rotate(" + a.toFixed(1) + " " + x.toFixed(0) + " " + y.toFixed(0) + ")",
                              fill: "url(#si-g-milk)" }, parent);
    }
    // the bulge: the same starlight, piled up toward the middle
    svgEl(svg, "ellipse", { cx: W * 0.5, cy: H * 0.5, rx: 330, ry: 210,
                            transform: "rotate(" + a.toFixed(1) + " " + (W * 0.5) + " " + (H * 0.5) + ")",
                            fill: "url(#si-g-milk)" }, parent);
  }
  function starDot(svg, parent, x, y, cls, mag, t_k) {
    var b = 7 - (mag == null ? 5 : mag);
    return svgEl(svg, "circle", {
      cx: (+x).toFixed(1), cy: (+y).toFixed(1), r: (b * 0.28 + 0.4).toFixed(2),
      fill: cls === "D" ? wdColor(t_k) : (CLS_COLOR[cls] || "#cfe0ff"),
      opacity: (0.22 + b * 0.075).toFixed(2), "class": "si-fstar"
    }, parent);
  }
  function speckle(svg, parent, seed, n, rad, conc, size, col, squash) {
    var rnd = mulberry32(seed || 7);
    for (var i = 0; i < n; i++) {
      var a = rnd() * 6.2832, rr = rad * Math.pow(rnd(), conc);
      svgEl(svg, "circle", { cx: (Math.cos(a) * rr).toFixed(1), cy: (Math.sin(a) * rr * (squash || 1)).toFixed(1),
                             r: size, fill: col, opacity: (0.35 + rnd() * 0.55).toFixed(2), "class": "si-speck" }, parent);
    }
  }

  function showGalaxy() {
    cosmos.view = "galaxy"; $("si-back-galaxy").hidden = true; clearMemPanel();
    var svg = freshSvg();
    var W = STARS.bounds.w, H = STARS.bounds.h;
    var pz = panZoom(svg, { x: 0, y: 0, w: W, h: H }, { x: W * 0.30, y: H * 0.28, w: W * 0.40, h: H * 0.44 });
    cosmos.panzoom = pz;
    skyDefs(svg);

    // Anything can be clicked for what it is. Extended objects get a bigger catch radius.
    var picks = [];
    function pick(x, y, r, desc) { picks.push({ x: +x, y: +y, r: r, d: desc }); }

    // draw order — nebulae and clusters behind, then the stars, then the things that are
    // neither: quasars from outside the galaxy, and the five that nobody has accounted for.
    var gMilk = svgEl(svg, "g", { "class": "si-neb" }), gDeep = svgEl(svg, "g", {}),
        gField = svgEl(svg, "g", {}), gOdd = svgEl(svg, "g", {}), gFar = svgEl(svg, "g", {}),
        gAnom = svgEl(svg, "g", {}), gLit = svgEl(svg, "g", {});
    milkyWay(svg, gMilk, W, H);

    (STARS.deep || []).forEach(function (d) {
      var g = svgEl(svg, "g", { transform: "translate(" + d.x + "," + d.y + ")", "class": "si-neb" }, gDeep);
      if (d.kind === "globular") {
        svgEl(svg, "circle", { cx: 0, cy: 0, r: d.r * 1.9, fill: "url(#si-g-cluster)" }, g);
        speckle(svg, g, d.seed, d.n, d.r, 2.2, 0.42, "#e8eeff", 1);
      } else if (d.kind === "open") {
        speckle(svg, g, d.seed, d.n, d.r, 0.85, 0.55, "#d3e2ff", 1);
      } else if (d.kind === "dwarf") {
        svgEl(svg, "ellipse", { cx: 0, cy: 0, rx: d.r, ry: d.r * 0.62, fill: "url(#si-g-dwarf)" }, g);
        speckle(svg, g, d.seed, 70, d.r * 0.8, 1.5, 0.3, "#ddd6ff", 0.62);
      } else if (d.kind === "dark") {
        // three overlapping lobes, so it comes out ragged rather than a clean ellipse
        var drnd = mulberry32(d.seed || 3);
        for (var q = 0; q < 3; q++) {
          var qa = drnd() * 6.2832, qd = d.r * 0.34 * drnd();
          svgEl(svg, "ellipse", { cx: (Math.cos(qa) * qd).toFixed(1), cy: (Math.sin(qa) * qd * 0.6).toFixed(1),
                                  rx: (d.r * (0.72 + drnd() * 0.5)).toFixed(1), ry: (d.r * (0.5 + drnd() * 0.3)).toFixed(1),
                                  transform: "rotate(" + Math.round(drnd() * 180) + ")", fill: "url(#si-g-dust)" }, g);
        }
      } else if (d.kind === "snr") {
        svgEl(svg, "circle", { cx: 0, cy: 0, r: d.r, "class": "si-snr",
                               "stroke-dasharray": "3 2.5 6 3" }, g);
        svgEl(svg, "circle", { cx: 0, cy: 0, r: d.r * 0.82, opacity: ".55", "class": "si-snr",
                               "stroke-dasharray": "2 5" }, g);
      } else {
        var fill = d.kind === "emission" ? "url(#si-g-emission)"
                 : d.kind === "reflection" ? "url(#si-g-reflection)" : "url(#si-g-planetary)";
        svgEl(svg, "ellipse", { cx: 0, cy: 0, rx: d.r, ry: d.r * (d.kind === "planetary" ? 0.9 : 0.72),
                                transform: "rotate(" + ((d.seed || 0) % 180) + ")", fill: fill }, g);
        // the star that lit it / the one it was shed from
        if (d.kind === "planetary") svgEl(svg, "circle", { cx: 0, cy: 0, r: 0.7, fill: "#dff0ff" }, g);
      }
      pick(d.x, d.y, Math.max(d.r, 8), describeDeep(d));
    });

    var lit = [];
    STARS.stars.forEach(function (s) {
      if (s.name && starLit(s)) { lit.push(s); return; }
      var desc = describeStar(s);
      if (!s.kind || s.kind === "wd") {
        // ordinary stars — and the multiples most of them turn out to be. The companions sit
        // close enough to read as one fat star until you zoom, which is how a double star
        // actually gives itself away.
        starDot(svg, gField, s.x, s.y, s.cls, s.mag, s.t_k);
        (s.comp || []).forEach(function (c) { starDot(svg, gField, s.x + c.dx, s.y + c.dy, c.cls, c.mag, 9000); });
        pick(s.x, s.y, 7, desc);
        return;
      }
      var g = svgEl(svg, "g", { transform: "translate(" + s.x + "," + s.y + ")" }, gOdd);
      if (s.kind === "pulsar") {
        var beams = svgEl(svg, "g", { "class": "si-spin" }, g);
        svgEl(svg, "path", { d: "M0 0 L 12 -1.9 L 12 1.9 Z", "class": "si-pulsar-beam" }, beams);
        svgEl(svg, "path", { d: "M0 0 L -12 -1.9 L -12 1.9 Z", "class": "si-pulsar-beam" }, beams);
        svgEl(svg, "circle", { cx: 0, cy: 0, r: 1.6, "class": "si-ping" }, g);
        svgEl(svg, "circle", { cx: 0, cy: 0, r: 1.1, "class": "si-pulsar-core" }, g);
        (s.comp || []).forEach(function (c) { starDot(svg, g, c.dx, c.dy, c.cls, c.mag, 9000); });
      } else if (s.kind === "bh") {
        var c0 = (s.comp || [])[0];
        if (s.mode === "quiet") {
          svgEl(svg, "circle", { cx: 0, cy: 0, r: 1.6, "class": "si-bh-quiet" }, g);
        } else {
          if (s.mode === "microquasar") {
            svgEl(svg, "line", { x1: 0, y1: -3, x2: 0, y2: -11, "class": "si-bh-jet" }, g);
            svgEl(svg, "line", { x1: 0, y1: 3, x2: 0, y2: 11, "class": "si-bh-jet" }, g);
          }
          svgEl(svg, "ellipse", { cx: 0, cy: 0, rx: 3.4, ry: 1.2, "class": "si-bh-ring" }, g);
          svgEl(svg, "circle", { cx: 0, cy: 0, r: 1.5, "class": "si-bh-disc" }, g);
          // the thread of gas coming off the companion
          if (c0) svgEl(svg, "path", { d: "M" + c0.dx + " " + c0.dy + " Q " + (c0.dx * 0.4) + " " + (c0.dy * 0.4 - 1.4) + " 0 0", "class": "si-stream" }, g);
        }
        if (c0) starDot(svg, g, c0.dx, c0.dy, c0.cls, c0.mag, 9000);
      } else if (s.kind === "smbh") {
        svgEl(svg, "circle", { cx: 0, cy: 0, r: 26, fill: "url(#si-g-core)" }, g);
        // the knot of stars on decade-long orbits — how you find a thing that gives off nothing
        var rnd = mulberry32(s.seed || 1);
        for (var i = 0; i < (s.s_stars || 9); i++) {
          var a = rnd() * 6.2832, rr = 5 + rnd() * 9;
          svgEl(svg, "ellipse", { cx: 0, cy: 0, rx: rr, ry: rr * (0.3 + rnd() * 0.5), opacity: ".18",
                                  transform: "rotate(" + (a * 57.3).toFixed(0) + ")", "class": "si-orbit" }, g);
          svgEl(svg, "circle", { cx: (Math.cos(a) * rr).toFixed(1), cy: (Math.sin(a) * rr * 0.5).toFixed(1),
                                 r: 0.7, fill: "#fff3d8", opacity: ".85" }, g);
        }
        svgEl(svg, "circle", { cx: 0, cy: 0, r: 4.6, "class": "si-bh-ring" }, g);
        svgEl(svg, "circle", { cx: 0, cy: 0, r: 4.0, "class": "si-bh-disc" }, g);
      }
      pick(s.x, s.y, s.kind === "smbh" ? 14 : 8, desc);
    });

    // beyond the galaxy entirely — and hiding from its dusty plane, which is why none of
    // them sit along the band: from in here, the view out is blocked.
    (STARS.agn || []).forEach(function (a) {
      var g = svgEl(svg, "g", { transform: "translate(" + a.x + "," + a.y + ")" }, gFar);
      if (a.z < 0.6) svgEl(svg, "ellipse", { cx: 0, cy: 0, rx: 4.2, ry: 2.6, fill: "url(#si-g-dwarf)",
                                             transform: "rotate(" + Math.round(a.jet * 30) + ")" }, g);
      svgEl(svg, "circle", { cx: 0, cy: 0, r: 3.4, fill: "url(#si-g-agn)" }, g);
      var jx = Math.cos(a.jet) * (a.kind === "blazar" ? 4 : 8), jy = Math.sin(a.jet) * (a.kind === "blazar" ? 4 : 8);
      svgEl(svg, "line", { x1: 0, y1: 0, x2: jx.toFixed(1), y2: jy.toFixed(1), "class": "si-jet",
                           opacity: a.kind === "blazar" ? ".35" : ".55" }, g);
      svgEl(svg, "circle", { cx: 0, cy: 0, r: a.kind === "blazar" ? 1.1 : 0.85, "class": "si-agn-core" }, g);
      pick(a.x, a.y, 7, describeAgn(a));
    });

    // ...and the five things in this catalogue that are not accounted for.
    (STARS.anomalies || []).forEach(function (a) {
      var g = svgEl(svg, "g", { transform: "translate(" + a.x + "," + a.y + ")", "class": "si-anom" }, gAnom);
      var R = a.r, rnd = mulberry32(R * 977 + a.x);
      // a faint smudge so the thing is findable at low zoom, without reading as a bubble up close
      svgEl(svg, "circle", { cx: 0, cy: 0, r: R * 1.7, fill: "url(#si-g-anom)" }, g);
      if (a.form === "swarm") {
        svgEl(svg, "circle", { cx: 0, cy: 0, r: 1.4, fill: "#ffe9c0", opacity: ".9" }, g);
        for (var i = 0; i < 40; i++) {                      // a ragged shoal of somethings, mid-transit
          var t = (i / 40) * 6.2832, rr = R * (0.62 + rnd() * 0.42);
          if (t > 4.4 && t < 5.4) continue;                 // the gap that makes the dips uneven
          svgEl(svg, "circle", { cx: (Math.cos(t) * rr).toFixed(1), cy: (Math.sin(t) * rr * 0.42).toFixed(1),
                                 r: (0.3 + rnd() * 0.35).toFixed(2), "class": "si-anom-dot", opacity: ".75" }, g);
        }
      } else if (a.form === "shell") {
        svgEl(svg, "circle", { cx: 0, cy: 0, r: R, "class": "si-anom-void", "stroke-dasharray": "2.2 1.6" }, g);
        svgEl(svg, "circle", { cx: 0, cy: 0, r: R * 0.55, "class": "si-anom-line", opacity: ".45",
                               "stroke-dasharray": "1.4 2.2" }, g);
      } else if (a.form === "ring") {
        svgEl(svg, "ellipse", { cx: 0, cy: 0, rx: R, ry: R * 0.13, "class": "si-anom-line",
                                transform: "rotate(-18)" }, g);
        svgEl(svg, "circle", { cx: 0, cy: 0, r: 1, "class": "si-anom-dot" }, g);
      } else if (a.form === "occulter") {
        // straight edges, which nature does not make
        var pts = [], k;
        for (k = 0; k < 6; k++) { var th = k * 1.0472 + 0.3; pts.push((Math.cos(th) * R).toFixed(1) + "," + (Math.sin(th) * R * 0.8).toFixed(1)); }
        svgEl(svg, "polygon", { points: pts.join(" "), "class": "si-anom-void" }, g);
      } else if (a.form === "arc") {
        svgEl(svg, "path", { d: "M " + (-R) + " 4 A " + R + " " + R + " 0 0 1 " + R + " 4", "class": "si-anom-line", opacity: ".5" }, g);
        for (var j = 0; j < 9; j++) {                        // nine, evenly spaced, holding station
          var ang = Math.PI + (j / 8) * Math.PI;
          svgEl(svg, "circle", { cx: (Math.cos(ang) * R).toFixed(1), cy: (Math.sin(ang) * R + 4).toFixed(1),
                                 r: 0.75, "class": "si-anom-dot" }, g);
        }
      }
      pick(a.x, a.y, R + 4, describeAnom(a));
    });

    lit.forEach(function (s) {
      var col = CLS_COLOR[s.cls] || "#ffd98a";
      var g = svgEl(svg, "g", { "class": "si-star si-star--blaze", tabindex: "0", role: "button" }, gLit);
      g.setAttribute("aria-label", s.name + ", a charted system.");
      svgEl(svg, "circle", { cx: s.x, cy: s.y, r: 15, "class": "halo", fill: col }, g);
      svgEl(svg, "circle", { cx: s.x, cy: s.y, r: 4.5, "class": "core", fill: col }, g);
      var t = svgEl(svg, "text", { x: s.x + 11, y: s.y + 4, "class": "si-starlabel" }, g); t.textContent = s.name;
      function info() { setSky("a charted system", s.name, s.note || "", s.system ? "Click to enter." : ""); }
      g.addEventListener("mouseenter", info);
      g.addEventListener("click", function (e) { e.stopPropagation(); if (pz.moved() > 5) return; if (s.system && SYSTEMS[s.system]) showSystem(s.system); else info(); });
      g.addEventListener("keydown", function (e) { if ((e.key === "Enter" || e.key === " ") && s.system) { e.preventDefault(); showSystem(s.system); } });
    });

    // click anything: nearest object wins, normalised by its own size so a nebula doesn't
    // swallow the stars inside it. The catch radius grows as you zoom out.
    svg.addEventListener("click", function (e) {
      if (pz.moved() > 5 || (e.target.closest && e.target.closest(".si-star"))) return;
      var w = pz.toWorld(e.clientX, e.clientY), slack = Math.max(1, pz.span() / 800);
      var best = null, bestScore = 1;
      picks.forEach(function (p) {
        var rr = p.r * slack, dx = p.x - w.x, dy = p.y - w.y, sc = (dx * dx + dy * dy) / (rr * rr);
        if (sc < bestScore) { bestScore = sc; best = p; }
      });
      if (best) setSky(best.d[0], best.d[1], best.d[2], best.d[3]);
    });

    setSky("", "The known sky",
      "Reading lights the stars that the books have named. Everything else is astronomy, and is " +
      "there whether or not anyone has written it down.",
      lit.length + (lit.length === 1 ? " system charted" : " systems charted") +
      " · drag to pan · scroll to zoom · click anything to see what it is.");
  }

  // Overlay a body's generated render (docs/assets/art/<sys>/<id>.png), circle-clipped
  // onto its disc. The palette disc stays underneath as the fallback: until the art is
  // generated (scripts/gen-art.py) the image 404s and hides itself, leaving the disc.
  function bodyArt(svg, parent, cx, cy, r, sysId, id) {
    var url = (window.SI_BASEURL || "") + "/assets/art/" + sysId + "/" + id + ".png";
    var cid = "cl-" + sysId + "-" + id;
    var cp = svgEl(svg, "clipPath", { id: cid });
    svgEl(svg, "circle", { cx: cx, cy: cy, r: r }, cp);
    var img = svgEl(svg, "image", {
      x: (cx - r).toFixed(1), y: (cy - r).toFixed(1),
      width: (r * 2).toFixed(1), height: (r * 2).toFixed(1),
      preserveAspectRatio: "xMidYMid slice", "clip-path": "url(#" + cid + ")",
      href: url, "class": "si-art"
    }, parent);
    img.addEventListener("error", function () { img.setAttribute("opacity", "0"); });
    return img;
  }

  function showSystem(sysId) {
    var sys = SYSTEMS[sysId]; if (!sys) { showGalaxy(); return; }
    cosmos.view = "system"; $("si-back-galaxy").hidden = !galaxyUnlocked(); clearMemPanel();
    var svg = freshSvg();
    var R = 560, pz = panZoom(svg, { x: -R * 2.4, y: -R * 2.4, w: R * 4.8, h: R * 4.8 }, { x: -R * 1.2, y: -R * 1.2, w: R * 2.4, h: R * 2.4 });
    cosmos.panzoom = pz;
    var planets = (sys.bodies || []).filter(function (b) { return b.kind === "planet"; });
    var belts = (sys.bodies || []).filter(function (b) { return b.kind === "belt"; });
    var maxAu = 1; planets.forEach(function (p) { if (p.orbit && p.orbit.au > maxAu) maxAu = p.orbit.au; });
    function rpx(au) { return R * Math.sqrt(au / maxAu); }
    planets.forEach(function (p) { svgEl(svg, "circle", { cx: 0, cy: 0, r: rpx(p.orbit.au).toFixed(1), "class": "si-orbit" }); });
    belts.forEach(function (b) { var ri = rpx(b.orbit.au_inner), ro = rpx(b.orbit.au_outer); for (var i = 0; i < 170; i++) { var ang = i * 2.399963; var rr = ri + (ro - ri) * ((i * 41 % 100) / 100); svgEl(svg, "circle", { cx: (Math.cos(ang) * rr).toFixed(1), cy: (Math.sin(ang) * rr).toFixed(1), r: 0.8, "class": "si-belt" }); } });
    var primary = (sys.stars || [])[0] || {}, sunCol = (primary.palette && primary.palette[0]) || "#ffd98a";
    svgEl(svg, "circle", { cx: 0, cy: 0, r: 30, "class": "si-sunglow", fill: sunCol });
    svgEl(svg, "circle", { cx: 0, cy: 0, r: 17, "class": "si-sun", fill: sunCol });
    if (primary.id) bodyArt(svg, svg, 0, 0, 17, sysId, primary.id);
    planets.forEach(function (p) {
      var ang = p.order * 1.7 + 0.6, rr = rpx(p.orbit.au), px = Math.cos(ang) * rr, py = Math.sin(ang) * rr;
      var pr = Math.max(3, Math.min(12, 3 + Math.log(((p.phys && p.phys.radius_e) || 1) + 0.6) * 3.3));
      var col = (p.palette && p.palette[0]) || "#9aa8c0";
      var g = svgEl(svg, "g", { "class": "si-planet", tabindex: "0", role: "button" });
      g.setAttribute("aria-label", p.name);
      svgEl(svg, "circle", { cx: px.toFixed(1), cy: py.toFixed(1), r: pr.toFixed(1), fill: col, "class": "si-pbody" }, g);
      bodyArt(svg, g, px, py, pr, sysId, p.id);
      (p.moons || []).forEach(function (m, j) { var ma = ang + 1.1 + j * 0.9, mr = pr + 5 + j * 4; svgEl(svg, "circle", { cx: (px + Math.cos(ma) * mr).toFixed(1), cy: (py + Math.sin(ma) * mr).toFixed(1), r: 1.5, fill: "#dce6ff", "class": "si-moon" }, g); });
      var lbl = svgEl(svg, "text", { x: (px + pr + 5).toFixed(1), y: (py + 4).toFixed(1), "class": "si-planetlabel" }, g); lbl.textContent = p.name;
      function pick() { setPlanetPanel(sys, p); }
      g.addEventListener("mouseenter", pick);
      g.addEventListener("click", function (e) { e.stopPropagation(); if (pz.moved() > 5) return; pick(); });
      g.addEventListener("keydown", function (e) { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); pick(); } });
    });
    setSky(primary.spectral || "solar system", sys.system.name, sys.system.summary || "", "Click a world for its stats. Drag to pan · scroll to zoom.");
  }

  function setPlanetPanel(sys, p) {
    var ph = p.phys || {}, ob = p.orbit || {};
    $("si-sp-cycle").textContent = p.common || ("world " + (p.order || ""));
    $("si-sp-title").textContent = p.name;
    $("si-sp-facet").textContent = "";
    var bits = [];
    if (ph.radius_e) bits.push(ph.radius_e + "× Earth");
    if (ph.gravity_g) bits.push(ph.gravity_g + " g");
    if (ph.day_hr) bits.push(ph.day_hr >= 48 ? Math.round(ph.day_hr / 24) + "-day day" : ph.day_hr + "h day");
    if (ph.mean_temp_c != null) bits.push(ph.mean_temp_c + "°C");
    if (ph.atmosphere) bits.push(ph.atmosphere);
    $("si-sp-blurb").textContent = (p.story ? p.story + "  " : "") + bits.join(" · ");
    var orb = [];
    if (ob.au) orb.push(ob.au + " AU");
    if (ob.period_yr) orb.push(ob.period_yr < 1 ? Math.round(ob.period_yr * 365) + "-day orbit" : ob.period_yr + "-yr orbit");
    if ((p.moons || []).length) orb.push(p.moons.length + (p.moons.length === 1 ? " moon" : " moons"));
    $("si-sp-status").textContent = orb.join(" · ");
    if (p.story && sys.system.star_ref) {
      var list = memoriesForStar(sys.system.star_ref);
      $("si-rec-head").hidden = !list.length; $("si-rec-head").textContent = "Memories of " + p.name;
      renderMemories(list);
    } else { clearMemPanel(); }
  }

  if ($("si-map-reset")) $("si-map-reset").addEventListener("click", function () { if (cosmos.panzoom) cosmos.panzoom.reset(); });
  if ($("si-back-galaxy")) $("si-back-galaxy").addEventListener("click", showGalaxy);

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
        var r = memoriesForStar(bk.id);
        var open = r.filter(function (x) { return x.unlocked; }).length;
        var cls = open ? "blaze" : (r.length ? "published" : (bk.status || "dark"));
        var g = el("g", { "class": "si-star si-star--" + cls, tabindex: "0", role: "button" }, gStars);
        g.setAttribute("aria-label", (bk.title || "An unnamed star") + ". " + statusLine(bk, r));
        var size = r.length ? 5 : (bk.status === "published" ? 4.5 : bk.status === "writing" ? 4 : bk.status === "planned" ? 3.4 : 2.4);
        el("circle", { cx: bk.x, cy: bk.y, r: size * 3.2, "class": "halo" }, g);
        el("circle", { cx: bk.x, cy: bk.y, r: size + 7, "class": "ring" }, g);
        el("circle", { cx: bk.x, cy: bk.y, r: size, "class": "core" }, g);
        function choose() {
          Object.keys(starEls).forEach(function (k) { starEls[k].classList.remove("is-selected"); });
          g.classList.add("is-selected");
          setPanel(bk, cy, r); renderMemories(r);
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
  function openInhabit(sliceId, memoryId) {
    if (!getKey()) { openSettings(); return; }
    state.sliceId = sliceId; var s = ARCHIVE[sliceId];
    var mem = memoriesFor(sliceId).filter(function (m) { return m.id === memoryId; })[0] || memoriesFor(sliceId)[0];
    if (!mem) return;
    state.memory = mem;
    $("si-inhabit-title").textContent = "Whose eyes?";
    $("si-inhabit-frame").textContent = mem.title + (mem.when ? " · " + mem.when : "") + " — you'll wake where they stand.";
    var grid = $("si-inhabit-grid"); grid.innerHTML = "";
    (mem.inhabit || []).forEach(function (id) {
      var c = s.characters[id]; if (!c) return;
      var per = (s.personas || {})[id] || {};
      var card = document.createElement("button"); card.type = "button"; card.className = "si-scene-card";
      card.innerHTML = '<span class="si-sc-tag"></span><span class="si-sc-name"></span><span class="si-sc-blurb"></span>';
      card.querySelector(".si-sc-tag").textContent = "inhabit";
      card.querySelector(".si-sc-name").textContent = c.name || id;
      card.querySelector(".si-sc-blurb").textContent = per.become || "";
      card.addEventListener("click", function () { startSession(id); });
      grid.appendChild(card);
    });
    entry.hidden = true; inhabit.hidden = false;
  }
  function startSession(charId) {
    var s = slice(), m = state.memory, c = s.characters[charId] || {};
    state.body = charId; state.location = m.start; state.messages = [];
    $("si-room-name").textContent = c.name || charId;
    $("si-room-when").textContent = m.title;
    transcript.innerHTML = ""; boundaryBox.hidden = true; input.disabled = false; sendBtn.disabled = false;
    inhabit.hidden = true; entry.hidden = true; room.hidden = false;
    var seed = "[Begin. The visitor opens their eyes inhabiting " + (c.name || charId) +
      " at the location id \"" + m.start + "\". Call enter_location for that id, then set the scene of their arrival in the world's voice — a paragraph or two — and stop, letting them act.]";
    state.messages.push({ role: "user", content: seed });
    snapshot = { len: 1, location: state.location }; turnEls = [];
    runOpening();
  }
  function leave() { state.sliceId = null; state.memory = null; state.body = null; state.messages = []; room.hidden = true; inhabit.hidden = true; entry.hidden = false; if (location.hash || location.search) history.replaceState(null, "", location.pathname); }
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
    if (pendingOpen && getKey()) { var p = pendingOpen; pendingOpen = null; openFromLink(p.slice, p.at); }
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

  // ---- deep-link from the reader: ?open=<slice>&at=<chapter> ----
  function openFromLink(sliceId, chapterKey) {
    if (!ARCHIVE[sliceId]) return;
    var star = ARCHIVE[sliceId].slice.star, all = memoriesFor(sliceId);
    if (chapterKey) markRead(star, chapterKey);   // you arrived here by reading the chapter
    var raw = chapterKey ? memoriesForChapter(sliceId, chapterKey) : all.map(function (m) { return { sliceId: sliceId, mem: m }; });
    var list = raw.map(function (it) { return { sliceId: it.sliceId, mem: it.mem, unlocked: memUnlocked(star, it.mem, all) }; });
    var openable = list.filter(function (x) { return x.unlocked; });
    if (openable.length === 1) { openInhabit(openable[0].sliceId, openable[0].mem.id); return; }
    renderMemories(list);
    var h = $("si-rec-head"); if (h) { h.hidden = false; h.scrollIntoView({ behavior: "smooth" }); }
  }

  // ---- boot ----
  showDefault(); buildModelOptions();
  var params = new URLSearchParams(location.search);
  var openParam = params.get("open"), atParam = params.get("at");
  if (openParam && ARCHIVE[openParam]) {
    if (getKey()) { openFromLink(openParam, atParam); }
    else { pendingOpen = { slice: openParam, at: atParam }; openSettings(); }
  } else if (!getKey()) {
    openSettings();
  }
})();
</script>
{% endraw %}
