# The Animation Decision Framework

Before writing any animation code, answer these questions in order:

The frequency table, the easing curves, and the duration table are shared with the
`review-animations` skill's rule catalog and live in one place there — see
[../../review-animations/STANDARDS.md](../../review-animations/STANDARDS.md) (sections
"Should it animate? (frequency table)", "Easing", and "Duration"). This file keeps the
question-by-question framing and the illustrative detail that file doesn't carry.

### 1. Should this animate at all?

**Ask:** How often will users see this animation?

→ STANDARDS.md § "Should it animate? (frequency table)" has the frequency table and the
never-animate-keyboard-actions rule (with the Raycast example).

### 2. What is the purpose?

Every animation must have a clear answer to "why does this animate?"

Valid purposes:

- **Spatial consistency**: toast enters and exits from the same direction, making swipe-to-dismiss feel intuitive
- **State indication**: a morphing feedback button shows the state change
- **Explanation**: a marketing animation that shows how a feature works
- **Feedback**: a button scales down on press, confirming the interface heard the user
- **Preventing jarring changes**: elements appearing or disappearing without transition feel broken

If the purpose is just "it looks cool" and the user will see it often, don't animate.

### 3. What easing should it use?

Is the element entering or exiting?
  Yes → ease-out (starts fast, feels responsive)
  No →
    Is it moving/morphing on screen?
      Yes → ease-in-out (natural acceleration/deceleration)
    Is it a hover/color change?
      Yes → ease
    Is it constant motion (marquee, progress bar)?
      Yes → linear
    Default → ease-out

→ STANDARDS.md § "Easing" has the custom cubic-bezier curves and the curve-resource links
(don't hand-roll from scratch).

**Never use ease-in for UI animations.** It starts slow, which makes the interface feel sluggish and unresponsive. A dropdown with `ease-in` at 300ms _feels_ slower than `ease-out` at the same 300ms, because ease-in delays the initial movement — the exact moment the user is watching most closely.

### 4. How fast should it be?

→ STANDARDS.md § "Duration" has the per-element duration table (button feedback, tooltips,
dropdowns, modals) and the perceived-performance notes (spinner speed, instant-tooltip skip,
the 300ms rule).
