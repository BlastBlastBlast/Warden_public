---
name: writing-plans
description: Use when you have a spec or an approved intent for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each slice, code, testing, docs they might need to check, how to test it. Give them the whole plan as vertical slices, each one built from bite-sized steps. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Input:** an architectural change arrives here with a `spec.md`. A bounded change arrives with only an `intent.md`, and the plan argues from that instead.

**Save plans to:** `docs/superpowers/changes/<YYYY-MM>-<slug>/plan.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## Slice Vertically

**The unit of work is a slice, not a layer and not a file.**

A slice cuts through every layer the change touches and ends in behaviour someone can watch happen. Slice one is the thinnest path that proves the approach — one case, one input, the happy path. Later slices add cases, edge handling and polish.

Ordering by layer is the failure mode this section exists to prevent. Every model, then every endpoint, then the UI leaves nothing demonstrable until the last day, and the first honest review arrives hours after the approach was already wrong.

- **Each slice ends in something you can demonstrate.** Write the command that demonstrates it. If you cannot write that command, it is not a slice.
- **Slice one proves the shape of the change.** It is allowed to be ugly. It is not allowed to be invisible.
- **The suite stays green at every slice boundary.** A slice that leaves a test failing until the next slice lands is not a slice. When a later slice moves something a current test asserts on, say so, and the move carries the assertion with it.
- **If the work genuinely resists slicing, say so in the plan and give the reason.** Some changes are one indivisible edit. Saying that is better than a fake decomposition.

## File Structure

Before defining slices, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in. This map informs the slices; it does not become the slice order.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

## Slice Right-Sizing

A slice is the smallest cut through the stack that someone can watch work. When drawing slice
boundaries: fold setup, configuration, scaffolding, and documentation steps into the slice whose
demonstration needs them; split only where a reviewer could meaningfully reject one slice while
approving its neighbour.

## Bite-Sized Step Granularity

Inside a slice, **each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Risk, And How Many Tests It Buys

Every slice records a risk assessment: **where this can fail, and what that failure costs.** The tests for that slice follow from that assessment.

**What the risk assessment buys is concentration, not subtraction.** It tells you where to put tests and how deep to go. It does not tell you to write fewer of them, and it never tells you to leave behaviour untested.

- **Concentrate tests where the risk assessment names a cost.** A payment boundary, a permission check and a data migration each earn several tests. A pass-through wrapper earns one.
- **Do not ask for one test per file.** Do not ask for one test per function. Neither number has anything to do with risk.
- **Do not ask for a test whose only purpose is raising coverage.** A test that cannot fail for a reason you can name is wasted code, and it slows every future run.
- **A slice that changes behaviour gets a test.** The `superpowers:test-driven-development` skill owns that rule and its exceptions are the only exceptions. A plan cannot write "no test" for behaviour.

Over-testing and under-testing are both failures. The first fills the suite with noise. The second is worse, because it is invisible until something breaks.

## Which Model Runs A Slice

Name a model **only for a slice that a subagent implements.** Stages the session runs itself — the interview, the spec, the plan, the review, the reconcile — run on whatever model the session runs, and the plan says nothing about them.

For a slice that goes to a subagent:
- Files, tests, approach and the code all stated in the plan → the cheap tier.
- Crosses files, or works from prose rather than literal code → the standard tier.

A slice that needs the most capable tier because the plan is vague is a planning failure. Sharpen the slice instead of upgrading the executor. `superpowers:subagent-driven-development` holds the full tier definitions and settles anything the plan does not name.

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan slice-by-slice. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec:** [path to the spec this plan implements, or the intent for a bounded
change — the plan argues from it, so it travels with the plan; executors read both]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every slice's requirements implicitly
include this section.]

---
```

## Slice Structure

````markdown
### Slice N: [What someone can watch work]

**Satisfies:** REQ-3, REQ-4.2  *(omit for a bounded change with no spec)*

**Demonstrate with:** `npm run dev && open http://localhost:3000/orders/1`

**Risk:** The status lookup hits the upstream API, which rate-limits at 50 rps.
A failure here shows a stale status to every customer. Tests concentrate on the
cache boundary; the template rendering gets none.

**Model:** cheap tier — files, tests and code are all stated below.
*(omit this field entirely when the session implements the slice itself)*

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this slice uses from earlier slices — exact signatures]
- Produces: [what later slices rely on — exact function names, parameter
  and return types. A slice's implementer sees only their own slice; this
  block is how they learn the names and types neighbouring slices use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Demonstrate the slice**

Run the demonstration command above. Expected: the order page shows a status.

- [ ] **Step 6: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Slice N" (repeat the code — the engineer may be reading slices out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any slice
- A slice with no demonstration command

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each requirement in the spec. Can you point to a slice that satisfies it? List any gaps.

**2. Vertical check:** Read the slice titles in order. Does each one name something a person could watch happen? A title like "add the data model" is a layer, not a slice — re-cut it.

**3. Slice one check:** Could someone run slice one and see the shape of the change? If slice one is invisible, the order is wrong.

**4. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**5. Type consistency:** Do the types, method signatures, and property names you used in later slices match what you defined in earlier ones? A function called `clearLayers()` in Slice 3 but `clearFullLayers()` in Slice 7 is a bug.

**6. Test sizing:** Count the tests. If the count tracks the number of files rather than the number of risks, re-read the risk assessments.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no slice, add the slice.

## Interrogate It Before Showing It

Answer these in the plan, not in conversation:

- What could this break?
- Which slice carries the most risk?
- What did you rule out, and why?

Rank the risks worst first. A plan with no risks section had no interrogation.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/changes/<slug>/plan.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per slice, review between slices, fast iteration

**2. Inline Execution** - Execute slices in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per slice + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
