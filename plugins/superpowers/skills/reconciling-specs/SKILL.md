---
name: reconciling-specs
description: Use after review passes and before a pull request opens, when the change has a spec.md - compares the spec to what actually shipped, gets a ruling on every divergence, and updates the spec so it still describes the system. NOT for reviewing code (use requesting-code-review), and NOT for a bounded change, which has no spec to reconcile.
---

# Reconciling Specs

The build always departs from the spec. Names change, an edge case turns out to be three,
something the spec required turns out to be wrong. That is normal.

What is not normal is throwing the spec away afterwards. A spec that stops describing the
system stops being worth writing, and then nobody writes the next one.

This skill makes the spec true again before the work leaves the branch.

**Announce at start:** "I'm using the reconciling-specs skill to check the spec against what shipped."

## When To Run

Run this when the change has a `spec.md` and review has passed.

**Skip it entirely when the change has no spec.** A bounded change went from intent straight
to a plan and has no contract to reconcile. Go to `superpowers:finishing-a-development-branch`.

## Step 1: Find The Divergences

Read `spec.md`. Read the diff of the whole branch:

```bash
git diff $(git merge-base HEAD <base-branch>)..HEAD
```

For every requirement, answer one question: **does the shipped code do this?**

A divergence is any of these:

- The code does something the spec does not describe.
- The code does not do something a MUST requires.
- The code does it differently — a different name, a different boundary, a different default.
- A requirement turned out to be unbuildable, and the build worked around it.

List them. Cite the requirement identifier for each one, and quote the line of code or the
file that shows it. A divergence you cannot point at is a suspicion, not a finding.

**Requirements that shipped as written do not go in the list.** Say how many there were and
move on.

## Step 2: Get A Ruling On Each One

Present the divergences to your human partner, one at a time, worst first. For each one there
are exactly two rulings:

- **"The spec was wrong."** Reality taught you something the spec did not know. The
  requirement changes to describe what shipped.
- **"The code is wrong."** The spec still holds and the build missed it. This becomes work,
  not a documentation edit.

Give them what they need to rule: the requirement, what shipped instead, and your reading of
which one is right. A recommendation is welcome. **Making the call yourself is not.**

If a ruling turns into work, that work happens before the pull request. Come back and
reconcile again afterwards.

## Step 3: Write The Rulings Into The Spec

For every "the spec was wrong" ruling:

- **Rewrite the requirement to describe what shipped.** Keep the same keyword discipline —
  one capitalized keyword, a named actor, a stated proof.
- **Keep the identifier.** `REQ-4.2` stays `REQ-4.2` even when its text changes completely. A
  plan step, a test and a review finding all cite that number.
- **Never renumber anything.** A requirement the change dropped becomes
  `REQ-4.2: withdrawn` with the reason, not a gap in the sequence.
- **Never touch a requirement that got no ruling.** Silence is not permission.

Add a short section at the end recording what changed and why:

```markdown
## Reconciled <YYYY-MM-DD>
- REQ-4.2 — the spec named the flag `--strict`. The build shipped `--exact` to match the
  three neighbouring flags. Ruling: the spec was wrong.
- REQ-7 — withdrawn. The upstream rate limit made the cache pointless. Ruling: the spec
  was wrong.
```

Check the prose:

```bash
python3 skills/asd-ste100/scripts/ste-lint.py docs/superpowers/changes/<slug>/spec.md
```

Commit as `docs: reconcile spec for <slug>`.

## Step 4: Hand Over

The spec now describes the system. The pull request body gets written from it.

- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch

## Red Flags

| Thought | Reality |
|---------|---------|
| "Only small things changed, the spec is close enough" | Close enough is how a spec stops being read. List them and rule on them. |
| "Obviously the spec was wrong here, I'll just update it" | Two rulings exist and neither is yours. Ask. |
| "This requirement no longer makes sense, I'll delete it" | Withdrawn requirements keep their number and gain a reason. Deleting one hides a decision. |
| "I'll renumber now that REQ-7 is gone" | Numbers are permanent. Every test and review finding cites them. |
| "The code is wrong, but the PR is nearly up" | Then the PR waits. Shipping against a known-wrong spec is how the next change inherits the bug. |
| "There's no spec, so I'll write one now" | No. A bounded change never had one. Go to the finish skill. |
