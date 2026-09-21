# Dial Reference

Full technical detail behind `DESIGN_VARIANCE`, `MOTION_INTENSITY`, `VISUAL_DENSITY`. Load this when setting dial values from a design read, or auditing whether shipped output matches the stated dials.

Baseline: **8 / 6 / 4**. Cross-references throughout the skill use exactly these three variable names — don't invent aliases like `LAYOUT_VARIANCE` or `ANIM_LEVEL`.

## Design read → dial values

| Signal | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| "minimalist / clean / calm / editorial / Linear-style" | 5-6 | 3-4 | 2-3 |
| "premium consumer / Apple-y / luxury / brand" | 7-8 | 5-7 | 3-4 |
| "playful / wild / Dribbble / Awwwards / experimental / agency" | 9-10 | 8-10 | 3-4 |
| "landing page / portfolio / marketing site (default)" | 7-9 | 6-8 | 3-5 |
| "trust-first / public-sector / regulated / accessibility-critical" | 3-4 | 2-3 | 4-5 |
| "redesign - preserve" | match existing | +1 | match existing |
| "redesign - overhaul" | +2 | +2 | match existing |

## Use-case presets

| Use case | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| Landing (SaaS, mainstream) | 7 | 6 | 4 |
| Landing (Agency / creative) | 9 | 8 | 3 |
| Landing (Premium consumer) | 7 | 6 | 3 |
| Portfolio (Designer / studio) | 8 | 7 | 3 |
| Portfolio (Developer) | 6 | 5 | 4 |
| Editorial / Blog | 6 | 4 | 3 |
| Public-sector service | 3 | 2 | 5 |
| Redesign - preserve | match | match+1 | match |
| Redesign - overhaul | +2 | +2 | match |

## What each level means

### DESIGN_VARIANCE (1-10)
- **1-3 (Predictable):** Symmetrical CSS Grid (12-col, equal fr-units), equal paddings, centered alignment.
- **4-7 (Offset):** `margin-top: -2rem` overlaps, varied image aspect ratios (4:3 next to 16:9), left-aligned headers over center-aligned data.
- **8-10 (Asymmetric):** Masonry layouts, CSS Grid with fractional units (`grid-template-columns: 2fr 1fr 1fr`), large empty zones (`padding-left: 20vw`).
- **Mobile:** at levels 4-10, collapse asymmetric layouts to a strict single column (`w-full`, `px-4`, `py-8`) below 768px — the asymmetry is a desktop device, not a mobile one.

### MOTION_INTENSITY (1-10)
- **1-3 (Static):** No automatic animation. CSS `:hover`/`:active` only. `prefers-reduced-motion` is effectively the default mode anyway.
- **4-7 (Fluid CSS):** `transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1)`-style transitions, `animation-delay` cascades for load-ins, focused on `transform`/`opacity`.
- **8-10 (Advanced choreography):** Scroll-triggered reveals, parallax, scroll-driven animation (CSS `animation-timeline` or GSAP ScrollTrigger), Motion hooks. A raw `window.addEventListener('scroll')` is off the table at every level — see `references/skeletons.md` for the allowed alternatives.

### VISUAL_DENSITY (1-10)
- **1-3 (Art gallery):** Generous white space, `py-32` to `py-48` section gaps.
- **4-7 (Daily app):** Standard web-app spacing, `py-16` to `py-24`.
- **8-10 (Cockpit):** Tight paddings, no card boxes, 1px lines separating data, `font-mono` for numbers.
