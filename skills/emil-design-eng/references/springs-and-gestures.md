# Spring Animations

Springs feel more natural than duration-based animations because they simulate real physics. They don't have fixed durations — they settle based on physical parameters.

The use cases (drag momentum, "alive" elements, interruptible gestures, decorative mouse-tracking), the spring configs (Apple-style and traditional physics), the bounce range, and the interruptibility advantage are shared with `review-animations` and live in
[../../review-animations/STANDARDS.md](../../review-animations/STANDARDS.md) § "Springs". This
file keeps the one example STANDARDS.md doesn't carry: a full spring-based mouse-tracking snippet.

### Spring-based mouse interactions

Tying visual changes directly to mouse position feels artificial because it lacks motion. Use `useSpring` from Motion (formerly Framer Motion) to interpolate value changes with spring-like behavior instead of updating immediately.

```jsx
import { useSpring } from 'framer-motion';

// Without spring: feels artificial, instant
const rotation = mouseX * 0.1;

// With spring: feels natural, has momentum
const springRotation = useSpring(mouseX * 0.1, {
  stiffness: 100,
  damping: 10,
});
```

This works because the animation is **decorative** — it doesn't serve a function. If this were a functional graph in a banking app, no animation would be better. Know when decoration helps and when it hinders.

# Gesture and Drag Interactions

The velocity threshold, damping-at-boundaries, pointer-capture, multi-touch-protection, and
friction-over-hard-stops rules are shared with `review-animations` and live in STANDARDS.md
§ "Gestures & drag". This file keeps the fuller code for the two patterns STANDARDS.md only
gives as a one-line formula.

### Momentum-based dismissal

Don't require dragging past a threshold. Calculate velocity: `Math.abs(dragDistance) / elapsedTime`. If velocity exceeds ~0.11, dismiss regardless of distance. A quick flick should be enough.

```js
const timeTaken = new Date().getTime() - dragStartTime.current.getTime();
const velocity = Math.abs(swipeAmount) / timeTaken;

if (Math.abs(swipeAmount) >= SWIPE_THRESHOLD || velocity > 0.11) {
  dismiss();
}
```

### Multi-touch protection

Ignore additional touch points after the initial drag begins. Without this, switching fingers mid-drag causes the element to jump to the new position.

```js
function onPress() {
  if (isDragging) return;
  // Start drag...
}
```
