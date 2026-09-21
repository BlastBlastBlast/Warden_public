# Motion Skeletons & Forbidden Patterns

Canonical code for the scroll-driven patterns that are easy to get subtly wrong, plus the animation approaches to avoid outright. Load this when implementing a sticky-stack, horizontal-pan, or any scroll-triggered reveal.

## Sticky-stack

A "card stack on scroll" needs to be a real sticky-stack, not a sequential reveal list. The most common failure is the trigger firing halfway through the scroll instead of pinning at the viewport top — fix with `start: "top top"`, not `"top center"` or `"top 80%"`.

```tsx
"use client";
import { useRef, useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useReducedMotion } from "motion/react";

gsap.registerPlugin(ScrollTrigger);

export function StickyStack({ cards }: { cards: React.ReactNode[] }) {
  const ref = useRef<HTMLDivElement>(null);
  const reduce = useReducedMotion();

  useEffect(() => {
    if (reduce || !ref.current) return;
    const ctx = gsap.context(() => {
      const cardEls = gsap.utils.toArray<HTMLElement>(".stack-card");
      cardEls.forEach((card, i) => {
        if (i === cardEls.length - 1) return;
        ScrollTrigger.create({
          trigger: card,
          start: "top top",                              // pin at viewport top
          endTrigger: cardEls[cardEls.length - 1],
          end: "top top",
          pin: true,
          pinSpacing: false,
        });
        gsap.to(card, {
          scale: 0.92,
          opacity: 0.55,
          ease: "none",
          scrollTrigger: {
            trigger: cardEls[i + 1],
            start: "top bottom",
            end: "top top",
            scrub: true,
          },
        });
      });
    }, ref);
    return () => ctx.revert();
  }, [reduce]);

  return (
    <div ref={ref} className="relative">
      {cards.map((card, i) => (
        <div
          key={i}
          className="stack-card sticky top-0 min-h-[100dvh] flex items-center justify-center"
        >
          {card}
        </div>
      ))}
    </div>
  );
}
```

Critical points: `start: "top top"`, `pin: true`, every card except the last is pinned, and the scale/opacity transform on each card is driven by the *next* card's scroll trigger so the previous one visibly shrinks as the next arrives.

## Horizontal-pan

Vertical scroll driving a horizontal slide. The common failure is the pan starting before the section is actually pinned, so the user sees half a slide — same fix, `start: "top top"`.

```tsx
"use client";
import { useRef, useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useReducedMotion } from "motion/react";

gsap.registerPlugin(ScrollTrigger);

export function HorizontalPan({ children }: { children: React.ReactNode }) {
  const wrap = useRef<HTMLDivElement>(null);
  const track = useRef<HTMLDivElement>(null);
  const reduce = useReducedMotion();

  useEffect(() => {
    if (reduce || !wrap.current || !track.current) return;
    const ctx = gsap.context(() => {
      const distance = track.current!.scrollWidth - window.innerWidth;
      gsap.to(track.current, {
        x: -distance,
        ease: "none",
        scrollTrigger: {
          trigger: wrap.current,
          start: "top top",                              // pin starts when section top hits viewport top
          end: () => `+=${distance}`,                    // scroll distance = track width minus viewport
          pin: true,
          scrub: 1,
          invalidateOnRefresh: true,
        },
      });
    }, wrap);
    return () => ctx.revert();
  }, [reduce]);

  return (
    <section ref={wrap} className="relative overflow-hidden">
      <div ref={track} className="flex h-[100dvh] items-center">
        {children}
      </div>
    </section>
  );
}
```

Critical points: `start: "top top"`, `pin: true`, `end: "+=${distance}"` (scroll length equals the horizontal travel needed), `scrub: 1`. The wrapper is pinned; the inner track slides horizontally as the user scrolls vertically.

## Scroll-reveal stagger (lighter alternative)

For a simple "items appear as they enter the viewport" with no pinning, Motion's `whileInView` is lighter than GSAP and needs no ScrollTrigger:

```tsx
"use client";
import { motion, useReducedMotion } from "motion/react";

export function RevealStagger({ items }: { items: string[] }) {
  const reduce = useReducedMotion();
  return (
    <ul className="grid gap-6">
      {items.map((item, i) => (
        <motion.li
          key={item}
          initial={reduce ? false : { opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{
            duration: 0.6,
            delay: i * 0.06,
            ease: [0.16, 1, 0.3, 1],
          }}
        >
          {item}
        </motion.li>
      ))}
    </ul>
  );
}
```

Use this for feature lists, testimonial grids, logo walls — anything that just needs "enter on scroll." Save GSAP for actual pin/scrub work.

## Patterns to avoid

- `window.addEventListener("scroll", ...)` — runs every scroll frame, jank-prone, no batching. Use Motion's `useScroll()`, GSAP's ScrollTrigger, IntersectionObserver, or CSS scroll-driven animations (`animation-timeline: view()`) instead.
- Custom scroll-progress calculations reading `window.scrollY` into React state — same re-render-every-frame problem.
- `requestAnimationFrame` loops that touch React state — use motion values (`useMotionValue` + `useTransform`) instead.
- Wrapping static content in Motion's `layout`/`layoutId` props "for safety" — costs measurement work for nothing. Reserve them for actual visible state changes (list reordering, expanding modals, shared elements between routes).
- Mismatched stagger setup — `staggerChildren` (Motion) or a CSS cascade (`animation-delay: calc(var(--index) * 100ms)`) needs the parent (`variants`) and children in the same client-component tree.

## Animation library choice

- **Motion (`motion/react`)** — default for UI, bento, and state-change motion.
- **GSAP + ScrollTrigger** — full-page scrolltelling and scroll hijacks; isolate in dedicated leaf components with `useEffect` cleanup.
- **Three.js / WebGL** — canvas backgrounds and 3D scenes; same isolation rule.
- Don't mix GSAP/Three.js with Motion in the same component tree — they fight over the same frames.
