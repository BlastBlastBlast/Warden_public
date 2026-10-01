# Performance Rules

The core GPU-only-properties rule, the "CSS beats JS under load" rule, and the WAAPI example are
shared with `review-animations` and live in one place — see
[../../review-animations/STANDARDS.md](../../review-animations/STANDARDS.md) § "Performance".
This file keeps the two illustrations STANDARDS.md doesn't carry.

### CSS variables are inheritable

Changing a CSS variable on a parent recalculates styles for all children. In a drawer with many items, updating `--swipe-amount` on the container causes expensive style recalculation. Update `transform` directly on the element instead.

→ STANDARDS.md § "Performance" has the before/after code for this.

### Framer Motion hardware acceleration caveat

Framer Motion's shorthand properties (`x`, `y`, `scale`) are NOT hardware-accelerated. They use `requestAnimationFrame` on the main thread. For hardware acceleration, use the full `transform` string:

(code in STANDARDS.md § "Performance")

This matters when the browser is simultaneously loading content, running scripts, or painting. At Vercel, the dashboard tab animation used Shared Layout Animations and dropped frames during page loads. Switching to CSS animations (off main thread) fixed it.
