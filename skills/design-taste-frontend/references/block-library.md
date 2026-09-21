# Block Library Contract

Schema for a project's reusable block library, if one accumulates over time. Not populated by default — this is the contract new blocks should follow so they stay consistent and drop-in-able.

## File location

```
skills/taste-skill/blocks/
  hero/
    asymmetric-split.md
    editorial-manifesto.md
    kinetic-type.md
    ...
  feature/
    bento-grid.md
    sticky-scroll-stack.md
    zig-zag.md
    ...
  social-proof/
  pricing/
  cta/
  footer/
  navigation/
  portfolio/
  transition/
```

## Required frontmatter

```yaml
---
name: asymmetric-split-hero
category: hero
dial_compatibility:
  variance: [6, 10]
  motion: [3, 10]
  density: [2, 5]
when_to_use: "Landing pages with one strong asset and one strong message. Default hero for SaaS, agency, premium consumer."
not_for: "Editorial / manifesto launches where the message IS the design."
stack: ["react", "next", "tailwind", "motion"]
---
```

## Required body sections

1. **Visual sketch** — short ASCII or description of the layout.
2. **Props API** — the component's interface.
3. **Code sketch** — minimal working implementation (Server Component default, Client island for motion).
4. **Mobile fallback** — explicit collapse rules for `< 768px`.
5. **Motion variants** — one variant per `MOTION_INTENSITY` band (1-3, 4-7, 8-10), with an explicit reduced-motion fallback.
6. **Dark-mode notes** — token strategy specific to this block.
7. **Anti-patterns** — common ways this block goes wrong.
8. **References** — links to real examples in production.

## Discipline

One block per file, and every block should work standalone — drop it into a page and it renders. Blocks that depend on a design system from `references/design-systems.md` live under `blocks/<category>/<name>--<system>.md` (e.g. `feature/bento-grid--material.md`).
