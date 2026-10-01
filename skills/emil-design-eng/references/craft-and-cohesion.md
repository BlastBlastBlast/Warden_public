# The Sonner Principles (Building Loved Components)

These principles come from building Sonner (13M+ weekly npm downloads) and apply to any component:

(This is product/library-design craft, not animation-value lookup — it isn't duplicated in `review-animations`.)

1. **Developer experience is key.** No hooks, no context, no complex setup. Insert `<Toaster />` once, call `toast()` from anywhere. The less friction to adopt, the more people will use it.

2. **Good defaults matter more than options.** Ship beautiful out of the box. Most users never customize. The default easing, timing, and visual design should be excellent.

3. **Naming creates identity.** "Sonner" (French for "to ring") feels more elegant than "react-toast". Sacrifice discoverability for memorability when appropriate.

4. **Handle edge cases invisibly.** Pause toast timers when the tab is hidden. Fill gaps between stacked toasts with pseudo-elements to maintain hover state. Capture pointer events during drag. Users never notice these, and that is exactly right.

5. **Use transitions, not keyframes, for dynamic UI.** Toasts are added rapidly. Keyframes restart from zero on interruption. Transitions retarget smoothly.

6. **Build a great documentation site.** Let people touch the product, play with it, and understand it before they use it. Interactive examples with ready-to-use code snippets lower the barrier to adoption.

## Cohesion, opacity+height, fresh eyes, and asymmetric timing

These are shared with `review-animations` and live in
[../../review-animations/STANDARDS.md](../../review-animations/STANDARDS.md):

- § "Cohesion" — matching motion to a component's personality, and why Sonner's `ease`-not-`ease-out`, slightly-slower timing feels cohesive with its design and name.
- § "Debugging" — reviewing animations with fresh eyes the next day.
- § "Asymmetric timing" — the hold-to-delete example (2s linear press, 200ms ease-out release).

## Debugging Animations

The slow-motion (2–5x, DevTools inspector) and frame-by-frame (Chrome DevTools Animations panel) techniques, and what to look for, live in STANDARDS.md § "Debugging". This file keeps the one
device-testing detail STANDARDS.md doesn't carry:

### Test on real devices

For touch interactions (drawers, swipe gestures), test on physical devices. Connect your phone via USB, visit your local dev server by IP address, and use Safari's remote devtools. The Xcode Simulator is an alternative but real hardware is better for gesture testing.
