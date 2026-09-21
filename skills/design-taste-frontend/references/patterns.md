# Supplementary Patterns Reference

Overflow detail that didn't need to live in the main skill body — load whichever subsection is relevant.

## Stack defaults

- **Framework:** React or Next.js, defaulting to Server Components. Global state only works in Client Components — wrap providers in a `"use client"` component in Next.js.
- **Styling:** Tailwind v4 by default (v3 only if the existing project demands it). For v4, don't use the `tailwindcss` PostCSS plugin directly — use `@tailwindcss/postcss` or the Vite plugin.
- **Animation:** Motion (formerly Framer Motion), imported from `motion/react` (`import { motion } from "motion/react"`). `framer-motion` still works as a legacy alias; prefer `motion/react` in new code.
- **Fonts:** `next/font` in Next.js, or self-hosted `@font-face` + `font-display: swap` otherwise. Don't link Google Fonts via a production `<link>` tag.

## State

- Local `useState`/`useReducer` for isolated UI.
- Global state (Zustand, Jotai, React context) only to avoid deep prop-drilling.
- Continuous, high-frequency values (mouse position, scroll progress, pointer physics, magnetic hover) go through Motion's `useMotionValue`/`useTransform`/`useScroll`, never `useState` — state re-renders the tree every frame and collapses on mobile.

## Icons

- Priority order: `@phosphor-icons/react`, `hugeicons-react`, `@radix-ui/react-icons`, `@tabler/icons-react`.
- `lucide-react` is discouraged as a default; fine when the user asks for it explicitly or the project already depends on it.
- Don't hand-roll SVG icon paths — install a second library or compose from primitives if a glyph is missing.
- One icon family per project; standardize `strokeWidth` globally (e.g. `1.5` or `2.0`).

## Responsiveness & layout mechanics

- Breakpoints: `sm 640`, `md 768`, `lg 1024`, `xl 1280`, `2xl 1536`.
- Contain page layouts with `max-w-[1400px] mx-auto` or `max-w-7xl`.
- `min-h-[100dvh]`, never `h-screen`, for full-height hero sections (avoids iOS Safari address-bar jump).
- CSS Grid over flexbox percentage math (`grid grid-cols-1 md:grid-cols-3 gap-6`, not `w-[calc(33%-1rem)]`).

## Materiality & shape

- Cards earn their place only when elevation communicates real hierarchy; otherwise `border-t`, `divide-y`, or negative space groups content instead.
- Tint shadows to the background hue — no pure-black drop shadows on light backgrounds.
- Above `VISUAL_DENSITY 7`, skip card containers entirely; let data breathe in a plain layout.
- Pick one corner-radius scale for the whole page: all-sharp (0), all-soft (12-16px), or all-pill (full radius on interactive elements). A mixed system needs a documented rule (e.g. "buttons are full-pill, cards are 16px, inputs are 8px") applied everywhere — round buttons in an otherwise-square layout is broken, not stylistic.

## Data & form patterns

Label above the input; helper text optional but present in markup; error text below the input; standard `gap-2` for input blocks. Never use a placeholder as a stand-in for a label.

## Long lists and spec sheets

A default `<ul>` with bullets or `divide-y` rows is the lazy choice once a list passes about 5 items. Reach instead for: a 2-column split with grouped items, a card grid (image + label per item), tabs/accordion for categorizable items, horizontal scroll-snap pills, a carousel for breadth-heavy content (testimonials, logos, capabilities), or a marquee for "lots of things that don't need individual attention."

Long product/spec tables (the recurring cookware/hardware/apparel pattern — ten rows each with a `border-b`) read as the AI default for that category. Alternatives: a 2-col card grid (spec name + large display value + one-line "why it matters"), scroll-snap horizontal pills, grouped chunks (cluster specs into 2-3 logical groups, one soft divider and heading per cluster), or a featured-vs-rest split (3-4 hero specs as large tiles, the rest behind a "view full specifications" disclosure).

## Copy discipline

Before shipping, re-read every visible string (headlines, subheads, eyebrows, buttons, body, captions, alt text, footer, errors) and flag anything grammatically broken, referentially unclear, or written like an LLM trying to sound thoughtful (forced metaphors, passive-aggressive humility, mock-poetic labels). Replace with a plain functional sentence when in doubt — boring copy beats AI-cute copy.

Numbers like `92%`, `4.1×`, `48k`, `5.8mm` should come from real data, be explicitly marked as mock (`<!-- mock -->`, "example"), or be dropped — don't invent engineering-precision numbers the brand hasn't earned.

Keep one copy register per page — don't mix technical mono, editorial prose, and marketing punch in the same composition unless the brand voice explicitly calls for it.

## Quotes & testimonials

Max 3 lines of quote body (never 6) — cut longer quotes rather than running them in full; very small footer-style testimonials can stretch slightly, but the spirit is "fits in a glance." Attribution is name + role + optionally company, never name alone. Use real typographic quote marks or none, never straight ASCII quotes.

## Dark mode token strategy

Pick one strategy and hold it for the whole project: Tailwind's `dark:` variant (pair every color utility with its dark counterpart, `bg-white dark:bg-zinc-950`) for utility-first projects, or CSS variables (`--surface`, `--surface-elevated`, `--text-primary`, `--accent`, swapped under `[data-theme="dark"]` or `prefers-color-scheme: dark`) for component libraries with built-in theming. Respect `prefers-color-scheme` by default; add a manual toggle only if either mode would lose real brand expression. When using a system with built-in theming (Radix Themes, shadcn/ui `<Theme>`), set the theme once at the layout root — don't let individual sections override it.

## Performance details

- `will-change: transform` sparingly, only on elements that actually animate.
- Apply grain/noise filters exclusively to a fixed, `pointer-events-none` layer (e.g. `fixed inset-0 z-[60] pointer-events-none`) — never on a scrolling container, which causes continuous GPU repaints and destroys mobile FPS.
- Watch bundle size — Motion isn't tiny, Three.js is large; lazy-load anything not above the fold.
- Keep z-index usage systemic (sticky nav, modals, overlays, grain layer) rather than scattering arbitrary `z-10`/`z-50` values; document the scale in a shared constants file.

## Redesign preservation checklist

Never change without explicit approval: URL structure/route slugs, primary nav labels, form field names or order (breaks analytics and autofill), the brand logo/wordmark, or existing legal/consent/cookie copy. Also preserve: copy voice (visual modernization isn't a content rewrite), existing accessibility wins (focus states, alt text, keyboard nav, contrast), and existing analytics event names tied to button/field/section IDs.
