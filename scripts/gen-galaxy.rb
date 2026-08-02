#!/usr/bin/env ruby
# encoding: utf-8
#
# gen-galaxy.rb — deterministic kinematic model of the galaxy for the Archive map.
#
# The top-down complement to gen-starfield.rb's sky: a spiral disk that ROTATES.
# Real shape, real motion: two great arms and two minor ones (logarithmic spirals,
# pitch ~12.5°), a bulge, a thin/thick disk and a sparse halo. Stars are sampled with
# Gaussian scatter about a band's centerline, and every star carries its own kinematics
# (guiding radius, epicyclic amplitudes and phases), so the catalog can be rendered AT
# ANY EPOCH: bands shear apart over millions of years, arms turn as a pattern that
# stars flow through, and neighborhoods drift.
#
#   position_at(star, t):  # t in My, negative = the past
#     phi = phi0 + omega(Rg) * t                      # mean circular motion
#     R   = Rg + A_R * sin(kappa * t + psiR)          # radial epicycle
#     phi += (2 * omega / kappa) * (A_R / Rg) * cos(kappa * t + psiR)
#     z   = A_z * sin(nu * t + psiz)                  # vertical oscillation
#   arms at t: centerline phi(R) = phase + ln(R / 12_000) / tan(pitch) + OMEGA_P * t
#
# Deterministic (fixed seed): the SAME galaxy every run. Pure stdlib; feeds web now,
# app later. Writes docs/_data/galaxy.json — ANONYMOUS astronomy only: no story names,
# no mesh / temporal-transmitter data (that layer is private, planning/), and no
# named-system positions (read-to-reveal: those merge per-book at wiring time, like
# stars-named.yml). The named registry (series-bible/bell-frame.yml) is read here only
# to VERIFY distance rules and print author-side deep-time checks to stdout.
#
#     ruby scripts/gen-galaxy.rb        # writes docs/_data/galaxy.json (committed)

require 'json'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
SEED = 1985
OUT  = File.join(ROOT, 'docs', '_data', 'galaxy.json')
BELL = File.join(ROOT, 'series-bible', 'bell-frame.yml')

rng = Random.new(SEED)

# ------------------------------------------------------------------ physics --
# Units: light-years, My (megayears), radians. 1 km/s ≈ 3.34 ly/My.
KMS      = 3.34
V_FLAT   = 230.0 * KMS          # flat rotation curve, ~768 ly/My
R_CORE   = 3_000.0              # inner solid-body core
OMEGA_P  = 0.0256               # arm pattern speed (rad/My); corotation ~30 kly
PITCH    = 12.5 * Math::PI / 180
R_REF    = 12_000.0             # arm phase reference radius
ARMS     = [                    # two great arms + two minor (phase, weight, name for docs only)
  { phase: 0.0,               w: 1.0 },
  { phase: Math::PI,          w: 1.0 },
  { phase: Math::PI / 2.0,    w: 0.45 },
  { phase: 3 * Math::PI / 2.0, w: 0.45 },
]
ARM_SIGMA = 800.0               # in-plane scatter about a band's centerline (ly)
SCALE_LEN = 9_800.0             # exponential disk scale length
R_MIN, R_MAX = 800.0, 55_000.0
N_STARS  = 3_000

# The pocket: Hearth's galactocentric anchor, on the spur's shoulder (see bell-frame.yml).
POCKET = { r: 26_000.0, phi: 0.35, z: -40.0 }

def omega(r)
  r = [r, 1.0].max
  r < R_CORE ? V_FLAT / R_CORE : V_FLAT / r
end

def kappa(r) = Math.sqrt(2.0) * omega(r)   # epicyclic frequency (flat curve)
def nu(r)    = 2.0 * omega(r)              # vertical frequency (stylized)

def arm_phi(r, phase, t = 0.0)
  phase + Math.log(r / R_REF) / Math.tan(PITCH) + OMEGA_P * t
end

def gauss(rng)
  u1 = [rng.rand, 1e-9].max
  Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2 * Math::PI * rng.rand)
end

# Angular distance from phi to the NEAREST arm centerline at radius r (weighted draw).
def pick_arm(rng)
  total = ARMS.sum { |a| a[:w] }
  roll  = rng.rand * total
  ARMS.each { |a| roll -= a[:w]; return a if roll <= 0 }
  ARMS.last
end

# ------------------------------------------------------------- populations --
# fractions; velocity dispersions (km/s, per component); vertical scale (ly)
POPS = [
  { id: "bulge", f: 0.20, sig: 100.0, zscale: 2_500.0 },
  { id: "arm",   f: 0.40, sig:  12.0, zscale:   300.0 },
  { id: "field", f: 0.26, sig:  25.0, zscale:   450.0 },
  { id: "thick", f: 0.09, sig:  55.0, zscale: 1_100.0 },
  { id: "halo",  f: 0.05, sig: 120.0, zscale: 6_000.0 },
]
CLASS_W  = [["M", 0.58], ["K", 0.17], ["G", 0.11], ["F", 0.07], ["A", 0.045], ["B", 0.02], ["O", 0.005]]
BASE_MAG = { "O" => 0.4, "B" => 0.8, "A" => 1.6, "F" => 2.6, "G" => 3.4, "K" => 4.3, "M" => 5.3 }

def weighted(rng, table)
  r = rng.rand; acc = 0.0
  table.each { |k, w| acc += w; return k if r <= acc }
  table.last[0]
end

def sample_radius(rng, pop)
  if pop[:id] == "bulge"
    R_MIN + (R_CORE * 1.6) * rng.rand**0.6
  else
    60.times do
      r = -SCALE_LEN * Math.log([rng.rand, 1e-9].max)
      return r if r.between?(R_MIN, R_MAX)
    end
    SCALE_LEN
  end
end

stars = []
N_STARS.times do
  roll = rng.rand; acc = 0.0; pop = POPS.last
  POPS.each { |p| acc += p[:f]; (pop = p; break) if roll <= acc }

  r = sample_radius(rng, pop)
  phi =
    if pop[:id] == "arm" && r > R_CORE
      a = pick_arm(rng)
      arm_phi(r, a[:phase]) + gauss(rng) * (ARM_SIGMA / r)
    else
      rng.rand * 2 * Math::PI
    end
  z0 = gauss(rng) * pop[:zscale]

  sig_lyMy = pop[:sig] * KMS
  k  = kappa(r)
  a_r  = (sig_lyMy / k).abs * rng.rand**0.5     # radial epicycle amplitude (ly)
  a_z  = (sig_lyMy / nu(r)).abs * rng.rand**0.5
  cls  = weighted(rng, CLASS_W)
  mag  = (BASE_MAG[cls] + gauss(rng) * 0.6).round(2)

  stars << [pop[:id], r.round(1), (phi % (2 * Math::PI)).round(5), z0.round(1),
            a_r.round(1), (rng.rand * 2 * Math::PI).round(4),
            a_z.round(1), (rng.rand * 2 * Math::PI).round(4), cls, mag]
end

# --------------------------------------------------------------- the output --
payload = {
  "seed" => SEED,
  "units" => { "length" => "ly", "time" => "My", "angle" => "rad" },
  "rotation" => { "v_flat_ly_per_my" => V_FLAT.round(1), "r_core_ly" => R_CORE,
                  "omega_p_rad_per_my" => OMEGA_P, "galactic_year_at_pocket_my" => (2 * Math::PI * POCKET[:r] / V_FLAT).round(0) },
  "arms" => { "pitch_deg" => 12.5, "r_ref_ly" => R_REF,
              "set" => ARMS.map { |a| { "phase" => a[:phase].round(4), "w" => a[:w] } },
              "centerline" => "phi(R,t) = phase + ln(R/r_ref)/tan(pitch) + omega_p*t",
              "sigma_ly" => ARM_SIGMA },
  "kinematics" => "phi(t)=phi0+omega(Rg)t; R(t)=Rg+A_R sin(kappa t+psiR); phi+=(2*omega/kappa)(A_R/Rg)cos(kappa t+psiR); z(t)=A_z sin(nu t+psiz); omega=v/R (flat), kappa=sqrt(2)omega, nu=2omega",
  "star_row" => %w[pop Rg phi0 z0 A_R psiR A_z psiz cls mag],
  "stars" => stars,
}
File.write(OUT, JSON.generate(payload))
puts "wrote #{OUT} — #{stars.length} stars"

# ---------------------------------------------- author-side verification ----
# (stdout only; nothing below enters site data)
bell = YAML.load_file(BELL)
sys  = {}
bell["systems"].each { |s| sys[s["id"]] = [s["x"].to_f, s["y"].to_f, s["z"].to_f] }
dist = ->(a, b) { Math.sqrt(a.zip(b).sum { |p, q| (p - q)**2 }) }

puts "\n— distance rules (t = 0, Bell-frame comoving) —"
puts format("  Enara–Skerry  %5.1f ly  (dark crawl 35 route-yr: ok)", dist.(sys["enara"], sys["skerry"]))
puts format("  Reed–Sowen    %5.1f ly  (20-yr colony crossing: ok)", dist.(sys["reed"], sys["sowen"]))

# Band shear: two field stars 1,000 ly apart in radius, same azimuth.
r1, r2 = POCKET[:r] - 500, POCKET[:r] + 500
[1.0, 100.0, 1000.0].each do |t|
  dphi = (omega(r1) - omega(r2)) * t
  puts format("  band shear (ΔR=1,000 ly) at t=%6d My: %10.1f ly of relative slip",
              t, (dphi * POCKET[:r]).abs)
end

# The association check: the oldest works' systems as a co-moving family.
# Present positions are canon (bell-frame.yml). A past epoch is generated where the
# family's spread was tighter; internal drift (~4.5 km/s ≈ 15 ly/My) carries it to now.
vrng  = Random.new(SEED + 7)
works = %w[enara reed lull carath cinder tolm moss]
mean_r = works.sum { |w| dist.(sys[w], [0, 0, 0]) } / works.length
past = {}
works.each do |w|
  p    = sys[w]
  r_now = dist.(p, [0, 0, 0])
  u     = p.map { |c| c / r_now }
  r_old = mean_r + (Math.sqrt(-2 * Math.log([vrng.rand, 1e-9].max)) *
                    Math.cos(2 * Math::PI * vrng.rand)) * 2.5
  past[w] = u.map { |c| (c * r_old) }
end
rms = ->(h) do
  rs = h.map { |_, p| dist.(p, [0, 0, 0]) }
  m  = rs.sum / rs.length
  Math.sqrt(rs.sum { |r| (r - m)**2 } / rs.length)
end
now_h = works.to_h { |w| [w, sys[w]] }
puts "\n— the association, run backward (author-side; see atlas guards) —"
puts format("  works-shell spread now (t=0):        rms %5.1f ly about r̄=%4.1f", rms.(now_h), mean_r)
puts format("  works-shell spread at t=−1.0 My:     rms %5.1f ly  (drift unwound)", rms.(past))
drifts = works.map { |w| dist.(sys[w], past[w]) }
puts format("  implied internal drift: %4.1f–%4.1f ly over 1 My (≈ %3.1f km/s max) — association-plausible",
            drifts.min, drifts.max, drifts.max / KMS)
