# Design System Reference

Load this when the design read points at a specific product design system, or when wiring up an aesthetic that has no official package.

## When the brief matches a real design system

| Brief reads as… | Reach for | Why |
|---|---|---|
| Microsoft / enterprise SaaS / dashboards | `@fluentui/react-components` or `@fluentui/web-components` | Official Fluent UI, Microsoft tokens, accessibility done |
| Google-ish UI, Material-flavored product | `@material/web` + Material 3 tokens | Official, theme-able via Material Theming |
| IBM-style B2B / enterprise analytics | `@carbon/react` + `@carbon/styles` | Official Carbon, mature data-density patterns |
| Shopify app surfaces | `polaris.js` web components / Polaris React | Required for Shopify admin UI |
| Atlassian / Jira-style product | `@atlaskit/*` + `@atlaskit/tokens` | Official Atlassian DS |
| GitHub-style devtool / community page | `@primer/css` or `@primer/react-brand` | Official Primer; Brand variant for marketing |
| Public-sector UK service | `govuk-frontend` | Legally/regulatorily expected |
| US public-sector / trust-first | `uswds` | Same |
| Fast local-business / agency MVP | Bootstrap 5.3 | Boring, fast, works |
| Modern accessible React foundation | `@radix-ui/themes` | Primitives + polished theme |
| Modern SaaS where you own the components | shadcn/ui (`npx shadcn@latest add ...`) | You own the code, easy to customize; never ship default state |
| Tailwind-based modern SaaS / AI marketing | Tailwind v4 utilities + `dark:` variant | Default for indie + small team builds |

When one of these matches, install and use the official package rather than recreating its CSS by hand, and don't import a system's tokens only to override most of them. Keep exactly one system per project — don't mix Fluent React with Carbon, or shadcn/ui into a Material 3 app.

## When the brief is an aesthetic, not a system

No single package owns these — build with native CSS + Tailwind + a maintained component library, and be explicit in code comments about what's borrowed inspiration versus official material.

| Aesthetic | Honest implementation |
|---|---|
| Glassmorphism / "frosted glass" | `backdrop-filter`, layered borders, highlight overlays. Provide a solid-fill fallback for `prefers-reduced-transparency`. |
| Bento (Apple-style tile grids) | CSS Grid with mixed cell sizes. No single library owns this. |
| Brutalism | Native CSS, monospace, raw borders. No library. |
| Editorial / magazine | Serif type, asymmetric grid, generous whitespace. No library. |
| Dark tech / hacker | Mono + accent neon, terminal motifs. No library. |
| Aurora / mesh gradients | SVG or layered radial gradients. No library. |
| Kinetic typography | Native CSS animations, scroll-driven animations, GSAP for hijacks. No library. |
| Apple Liquid Glass | Apple documents this for Apple platforms only — there is no official `liquid-glass.css`. Web implementations are approximations using `backdrop-filter` + layered borders + highlights; label them clearly as approximations. |

## Install commands

```bash
# Material Web (Material 3)
npm install @material/web

# Fluent UI React (v9)
npm install @fluentui/react-components

# Fluent UI Web Components (framework-free)
npm install @fluentui/web-components @fluentui/tokens

# IBM Carbon
npm install @carbon/react @carbon/styles

# Radix Themes
npm install @radix-ui/themes

# shadcn/ui (open code, owned components)
npx shadcn@latest init
npx shadcn@latest add button card badge separator input

# Primer CSS (GitHub product/devtool UI)
npm install --save @primer/css

# Primer Brand (GitHub marketing UI)
npm install @primer/react-brand

# GOV.UK Frontend
npm install govuk-frontend

# USWDS (US Web Design System)
npm install uswds

# Atlassian Design System (Atlaskit)
yarn add @atlaskit/css-reset @atlaskit/tokens @atlaskit/button @atlaskit/badge @atlaskit/section-message @atlaskit/card

# Bootstrap 5.3
npm install bootstrap

# Shopify Polaris Web Components (Shopify apps only)
# Add this to your app HTML head:
#   <meta name="shopify-api-key" content="%SHOPIFY_API_KEY%" />
#   <script src="https://cdn.shopify.com/shopifycloud/polaris.js"></script>
```

## Canonical sources

**Material Web** — https://github.com/material-components/material-web · https://material-web.dev/theming/material-theming/ · https://m3.material.io/develop/web

**Fluent UI** — https://fluent2.microsoft.design/get-started/develop · https://fluent2.microsoft.design/components/web/react/ · https://github.com/microsoft/fluentui · https://learn.microsoft.com/en-us/fluent-ui/web-components/

**Carbon** — https://carbondesignsystem.com/ · https://github.com/carbon-design-system/carbon · https://carbondesignsystem.com/developing/react-tutorial/overview/ · https://carbondesignsystem.com/developing/web-components-tutorial/overview/

**Shopify Polaris** — https://shopify.dev/docs/api/app-home/web-components · https://github.com/Shopify/polaris-react · https://polaris-react.shopify.com/components

**Atlassian** — https://atlassian.design/get-started/develop · https://atlassian.design/components/button/examples · https://atlaskit.atlassian.com/packages/design-system/button/example/disabled · https://atlassian.design/tokens/design-tokens

**Primer** — https://primer.style/ · https://github.com/primer/css · https://github.com/primer/brand

**GOV.UK** — https://design-system.service.gov.uk/components/button/ · https://design-system.service.gov.uk/styles/layout/ · https://github.com/alphagov/govuk-frontend

**USWDS** — https://designsystem.digital.gov/documentation/developers/ · https://designsystem.digital.gov/components/button/ · https://designsystem.digital.gov/components/card/ · https://github.com/uswds/uswds

**Bootstrap** — https://getbootstrap.com/docs/5.3/layout/grid/ · https://getbootstrap.com/docs/5.3/components/card/

**Tailwind** — https://tailwindcss.com/docs/dark-mode · https://tailwindcss.com/blog/tailwindcss-v4

**Radix** — https://www.radix-ui.com/themes/docs/components/theme · https://www.radix-ui.com/themes/docs/components/card · https://github.com/radix-ui/themes

**shadcn/ui** — https://ui.shadcn.com/docs · https://ui.shadcn.com/docs/components/card · https://github.com/shadcn-ui/ui

**Native CSS / W3C** — https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/backdrop-filter · https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@media/prefers-color-scheme · https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@media/prefers-reduced-motion · https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Grid_layout · https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Scroll-driven_animations · https://drafts.csswg.org/scroll-animations-1/

**Apple Liquid Glass (Apple platforms only)** — https://developer.apple.com/design/human-interface-guidelines/materials · https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass · https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass · https://developer.apple.com/documentation/SwiftUI/Material

## Apple Liquid Glass: honest web approximation

Apple documents Liquid Glass in its Human Interface Guidelines and Developer Documentation for Apple platforms — a dynamic material used across Apple platform UI, implemented through Apple's native platform APIs, not a public web CSS package. There is no `liquid-glass.css` from Apple for ordinary websites.

A web approximation can combine `backdrop-filter`, transparent backgrounds, layered borders, highlight overlays, gradients, and motion with strong contrast fallbacks — but that's web glassmorphism / frosted-glass approximation, not official Apple Liquid Glass. Label it as such in code comments.

```css
.liquid-glass-web-approx {
  position: relative;
  isolation: isolate;
  overflow: hidden;
  border-radius: 999px;
  border: 1px solid rgb(255 255 255 / .32);
  background:
    linear-gradient(135deg, rgb(255 255 255 / .30), rgb(255 255 255 / .08)),
    rgb(255 255 255 / .12);
  backdrop-filter: blur(24px) saturate(180%) contrast(1.05);
  -webkit-backdrop-filter: blur(24px) saturate(180%) contrast(1.05);
  box-shadow:
    inset 0 1px 0 rgb(255 255 255 / .48),
    inset 0 -1px 0 rgb(255 255 255 / .12),
    0 18px 60px rgb(0 0 0 / .18);
}

.liquid-glass-web-approx::before {
  content: "";
  position: absolute;
  inset: 0;
  z-index: -1;
  border-radius: inherit;
  background:
    radial-gradient(circle at 20% 0%, rgb(255 255 255 / .55), transparent 34%),
    linear-gradient(90deg, rgb(255 255 255 / .18), transparent 42%, rgb(255 255 255 / .14));
  pointer-events: none;
}

.liquid-glass-web-approx::after {
  content: "";
  position: absolute;
  inset: 1px;
  border-radius: inherit;
  border: 1px solid rgb(255 255 255 / .14);
  pointer-events: none;
}

@media (prefers-color-scheme: dark) {
  .liquid-glass-web-approx {
    border-color: rgb(255 255 255 / .18);
    background:
      linear-gradient(135deg, rgb(255 255 255 / .16), rgb(255 255 255 / .04)),
      rgb(15 23 42 / .42);
    box-shadow:
      inset 0 1px 0 rgb(255 255 255 / .22),
      0 18px 60px rgb(0 0 0 / .42);
  }
}

@media (prefers-reduced-transparency: reduce) {
  .liquid-glass-web-approx {
    background: rgb(255 255 255 / .96);
    backdrop-filter: none;
    -webkit-backdrop-filter: none;
  }
}
```

`prefers-reduced-transparency` has uneven browser support — test it, and make sure there's enough contrast even without the blur.
