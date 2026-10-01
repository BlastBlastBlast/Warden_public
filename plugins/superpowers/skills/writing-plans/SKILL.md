---
name: writing-plans
description: Use when you have a spec or an approved intent for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans for an engineer who can read the repository but has never seen this codebase. Give each task its files, the behaviour it builds and the requirement that behaviour satisfies, the tests it writes and what each one asserts, and its test command — not the code itself, which the implementer reads in the repo. Give them the whole plan as a list of tasks, grouped into waves so a controller can dispatch a wave's tasks together. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Input:** an architectural change arrives here with a `spec.md`. A bounded change arrives with only an `intent.md`, and the plan argues from that instead.

**Save plans to:** `docs/superpowers/changes/<YYYY-MM>-<slug>/plan.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in. This map informs the tasks and their waves; it does not become the wave order.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

## Task Sizing

**The unit of work is a task: one independent unit, not a layer and not a count of files or steps.**
One subagent implements one task.

- **Size by independence, not by a limit.** Do not cap a task by the number of files it touches or
  the number of steps it has. A task is right-sized when it is one independent unit of work, however
  many files or steps that takes.
- **Small edits of the same kind across many files are one task.** A rename that touches ten call
  sites, or the same one-line fix applied to every skill file, does not need ten tasks.
- **Each top-level requirement maps to one task or more.** Walk the spec's top-level requirements
  and point to the task that satisfies each one.
- **A sub-requirement never owns a task.** Its parent requirement's task carries it. A task's
  **Satisfies** field lists only top-level requirement IDs.
- **If the work genuinely resists decomposition, say so in the plan and give the reason.** Some
  changes are one indivisible edit. Saying that is better than a fake decomposition.

## Bite-Sized Step Granularity

Inside a task, **each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step

## Risk, And How Many Tests It Buys

The plan carries one risk list for the whole plan (see "Interrogate It Before Showing It"), not one
per task. That list still names **where this can fail, and what that failure costs.** The tests for
each task follow from that.

**What the risk list buys is concentration, not subtraction.** It tells you where to put tests and
how deep to go. It does not tell you to write fewer of them, and it never tells you to leave
behaviour untested.

- **Concentrate tests where the risk list names a cost.** A payment boundary, a permission check and
  a data migration each earn several tests. A pass-through wrapper earns one.
- **Do not ask for one test per file.** Do not ask for one test per function. Neither number has
  anything to do with risk.
- **Do not ask for a test whose only purpose is raising coverage.** A test that cannot fail for a
  reason you can name is wasted code, and it slows every future run.
- **A task that changes behaviour gets a test.** The `superpowers:test-driven-development` skill
  owns that rule and its exceptions are the only exceptions. A plan cannot write "no test" for
  behaviour.

Over-testing and under-testing are both failures. The first fills the suite with noise. The second
is worse, because it is invisible until something breaks.

**A code task follows TDD:** write the test, see it fail, implement, see it pass. **A documentation
or configuration task writes no test-writing step.** It MAY name a check command that already
exists — a lint, a `git grep`, a diff — instead of writing one. The plan contains no task whose only
purpose is to build test tooling that the spec does not require.

## Which Model Runs A Task

`Model` is a task field. Name a model **only for a task that a subagent implements.** Stages the
session runs itself — the interview, the spec, the plan, the review, the reconcile — run on whatever
model the session runs, and the plan says nothing about them.

For a task that goes to a subagent:
- Its files, behaviour and tests are all stated below, and it touches one production file → the
  cheap tier.
- It crosses files → the standard tier.

A task that needs the most capable tier because the plan is vague is a planning failure. Sharpen
the task instead of upgrading the executor. `superpowers:subagent-driven-development` holds the
full tier definitions and settles anything the plan does not name.

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan wave by wave. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec:** [path to the spec this plan implements, or the intent for a bounded
change — the plan argues from it, so it travels with the plan; executors read both]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

---
```

## Task Structure

Each task lists its files, the behaviour it builds and the requirement that behaviour satisfies,
and its steps. The implementer sees only its own task's brief, so a task states what it does in its
own words — it never points at another task's text for the content. The one code the plan does
carry — an exact signature more than one task uses, or a value the spec gives — goes in the task's
**Interfaces** block, not in prose.

````markdown
### Task N: [What this task builds, in its own words]

**Satisfies:** REQ-3, REQ-4  *(top-level requirement IDs only; omit for a bounded change with no spec)*

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Depends on:** none *(or the task numbers this one needs to land first)*

**Model:** cheap tier — files, behaviour and tests are all stated below, and the task touches one
production file. *(write `session` when the session implements the task itself)*

**Interfaces:** *(omit when this task shares no interface with another task)*
- Consumes: [what this task uses from an earlier task — exact signatures]
- Produces: [what a later task relies on — exact function names, parameter
  and return types. A task's implementer sees only its own brief; this block
  is how it learns the names and types neighbouring tasks use.]

**Brief:** [what this task builds and why, in the task's own words — the behaviour, the tests it
writes and what each one asserts, and its test command]

**Steps:**
- [ ] Write the failing test.
- [ ] Run it and see it fail with "function not defined".
- [ ] Write the function: read the cache; on a hit younger than 60 seconds return it; on a miss,
  call the upstream API and populate the cache.
- [ ] Run the test and see it pass.
````

## Waves

After the task list, group the tasks into waves.

- **A wave is a group of tasks that share no owned file and that depend only on earlier waves.**
  Two tasks in one wave never touch the same file.
- **A task goes in the first wave after all the waves of the tasks it depends on.** A task with no
  dependency can go in wave 1.
- **Use the fewest waves the dependencies allow.** Do not spread independent tasks across waves for
  no reason — put everything that can run together in the same wave.

```markdown
## Waves

| Wave | Tasks | Why |
|---|---|---|
| 1 | 1, 2, 3 | Each task owns different files. |
| 2 | 4 | It depends on Task 2 and Task 3. |

After the last wave: the final review, the fix wave and the scoped re-review, then
`reconciling-specs`.
```

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without stating what the test asserts)
- "Similar to Task N" — the implementer sees only its own task's brief, so each task says what
  it does in its own words.
- References to types, functions, or methods not defined in any earlier task

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each top-level requirement in the spec. Can you point to a task that satisfies it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier ones? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Test sizing:** Count the tests. If the count tracks the number of files rather than the number of risks, re-read the risk list.

**5. Wave check:** For each wave, list the files its tasks own. If two tasks in the same wave own the same file, split the wave.

**6. Dependency check:** For each task's "Depends on", confirm the tasks it names sit in an earlier wave. A task cannot depend on a task in its own wave or a later one.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Interrogate It Before Showing It

Answer these in the plan, not in conversation, as one risk list for the whole plan — not one per
task:

- What could this break?
- Which task carries the most risk?
- What did you rule out, and why?

Rank the risks worst first. A plan with no risk list had no interrogation.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/changes/<slug>/plan.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - dispatches every task of a wave to a parallel subagent, then one final review of the whole branch after the last wave

**2. Inline Execution** - runs the waves in order in this session using executing-plans, one task at a time, then the same final review

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
