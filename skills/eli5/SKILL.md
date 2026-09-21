---
name: eli5
description: Explain a topic like I'm five, as an HTML artifact built from big pictures and few words. Use when the user types /eli5 <topic>, says they do not understand something, or asks for a dead-simple picture explainer of how something works. Not for API reference, not for a design document, and not for explaining a change you just made.
---

# eli5

Explain like I'm someone who knows nothing about this topic, using an HTML artifact with big pictures and
few words.

Topic: $ARGUMENTS

## How to do it

- Start from what the reader already knows. One familiar thing, then one step away from it.
- Pictures carry the explanation. Words label the pictures.
- No jargon. If a term is unavoidable, draw it before you name it.
- One idea per screen. If you need a second idea, you need a second screen.
- End with the thing they can now do or recognize.

If the topic is a system in this repo, read the code first so the picture is true. When the explanation
needs an accurate architecture, sequence or data-flow diagram rather than a friendly cartoon, use the
`diagram-design` skill instead.

## Source

Adapted from the `eli5` plugin by Thariq Shihipar,
[anthropics/claude-plugins-community](https://github.com/anthropics/claude-plugins-community), MIT.
