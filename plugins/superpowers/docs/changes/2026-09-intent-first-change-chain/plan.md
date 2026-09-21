# Plan: an intent-first change chain

Spec: `spec.md`. Intent: `intent.md`. Date: 2026-09-18. Status: draft.

## How this plan reads

The work changes seven skills, adds two, vendors one, and rewrites the two instruction files.

**This plan names no model for most of its steps.** REQ-6.3 restricts a model choice to a slice that a
subagent implements. Every slice below rewrites behavior-shaping prose in the session itself, so each
one runs on whatever model the session runs. Three steps go to a subagent, and only those three carry a
model.

Anchors in this plan name a section heading, not a line number. Headings survive an edit above them.
All anchors are correct at commit `de53d70`.

## Preparation

**P1. Record the eval baseline.** Run `bun run quorum check` in `evals/` and save the result. Then
record the pass state of the 33 scenarios that the spec names under FC-7. This is the "before" half of
REQ-10.10. Without it the change has no evidence.

Subagent step. Model: Sonnet. The command and the output path are both known.

**P2. Vendor the ASD-STE100 package.** Copy `~/.claude/skills/asd-ste100/` to `skills/asd-ste100/`.
The package holds `SKILL.md`, `references/writing-rules.md`, `examples/before-after.md`,
`scripts/ste-lint.py` and an MIT `LICENSE`. The copy satisfies REQ-10.2, REQ-10.3 and REQ-10.4 in one
move, and it removes the plugin's last reason to reach outside itself.

Check afterwards that `python3 skills/asd-ste100/scripts/ste-lint.py` runs on a file inside the
repository and that no path inside the copied files points at `~/.claude`.

Subagent step. Model: Sonnet. The source, the destination and the check are all known.

## Slice 1 — an intent arrives before anything else

Satisfies REQ-1, REQ-2, REQ-9, REQ-10.5.

This is the thinnest path that proves the whole idea. A bounded change runs end to end through the new
order, and no other stage changes yet.

**What changes.** In `skills/brainstorming/SKILL.md`, the "Three Paths" section moves below a new
interview section. The checklists in "Checklist" gain the intent steps and lose the classification
from their first position. The "Process Flow" graph changes to match. The terminal-state paragraph
after that graph names `writing-specs` as a third destination.

In `skills/using-superpowers/SKILL.md`, the "Skill Priority" section gains the empty prompt and the
vague prompt as triggers for `brainstorming`.

The intent document stays in the conversation until the class is known. `brainstorming` writes
`docs/superpowers/changes/<YYYY-MM>-<slug>/intent.md` for a bounded change and for an architectural
change, and writes nothing for a spike.

**How to demonstrate it.** Open a clean session. Send "let's make a react todo list". Watch the
interview run one question per message, watch the intent appear in the conversation, approve it, watch
the class get announced, and watch `intent.md` get written and committed.

**What proves it.** A recorded transcript of that session. Then re-run the four `brainstorming`
scenarios in the harness and record the result against the baseline from P1.

**Risk this slice carries.** `brainstorming` holds a `<HARD-GATE>` block and a Red Flags table that the
repository protects by name. The edit keeps both and changes only the order of the steps they govern.

## Slice 2 — the spec stage writes a real spec

Satisfies REQ-3, REQ-9.3, REQ-10.6, REQ-10.7, and it consumes P2.

**What changes.** A new `skills/writing-specs/SKILL.md`. It takes an approved intent and writes
`spec.md` as numbered requirements with one RFC 2119 keyword each, a named actor, a stated proof and
stable identifiers. It reports a contradiction as a flagged concern and never picks a side. It runs
`skills/asd-ste100/scripts/ste-lint.py` on its own output before it hands over, and it invokes
`writing-plans` after approval.

`skills/brainstorming/SKILL.md` routes an architectural change to this skill.

**How to demonstrate it.** Give the chain an architectural request. Watch a `spec.md` appear that the
vendored checker passes with no hard violation.

**What proves it.** The checker's exit code on the generated spec, plus a read of that spec for a
keyword, an identifier, an actor and a proof in every requirement. The three spec scenarios in the
harness run against the baseline.

**Note for the executor.** This spec and this plan were written by the shepherd skills of the same
name. Read `~/.claude/skills/author-spec/` for the method, then write the plugin's own version that
depends on nothing outside the plugin. Copying the file would violate REQ-10.1.

## Slice 3 — the plan slices vertically and names its models

Satisfies REQ-4.1 through REQ-4.5, REQ-5.1, REQ-5.2, REQ-5.6, REQ-5.7, REQ-5.8, REQ-5.9, REQ-6.1,
REQ-6.2, REQ-6.3.

**What changes.** In `skills/writing-plans/SKILL.md`, the "File Structure" and "Task Right-Sizing"
sections give up the task as the unit of work. A slice replaces it. "Bite-Sized Task Granularity"
keeps its step size inside a slice. The "Task Structure" template gains three fields: the requirement
identifiers the slice satisfies, the risk assessment with the tests that follow from it, and the model
for a slice that a subagent implements. The "Plan Document Header" gains a demonstration command per
slice.

The risk assessment sizes the tests. It never removes them from behavior. The template says that a
slice concentrates its tests where the risk assessment names a cost, that one test for each file and
one test for each function are both wrong, and that a test which only raises coverage is wasted code.

**How to demonstrate it.** Point the skill at this repository's own `spec.md` and watch it produce a
plan whose slice one crosses every layer that the change touches.

**What proves it.** A read of the generated plan for the three new fields, and a check that no slice
groups work by layer. The `writing-plans-no-spec-conversational` scenario runs against the baseline.

**Risk this slice carries.** Low. The old template hard-codes a test step in every task and that step
stays. The change is the breadth of what the plan asks for, not the presence of a test.

## Slice 4 — execution obeys the plan

Satisfies REQ-4.6, REQ-4.7, REQ-5.3, REQ-5.4, REQ-5.5, REQ-6.4 through REQ-6.8.

**`skills/test-driven-development/SKILL.md` does not change.** REQ-5.5 keeps the Iron Law, REQ-5.3 and
REQ-5.4 keep the failing test first, and REQ-5.9 keeps the three existing exceptions as the only
exceptions. Slice 3 carries the whole of the test change, and it carries it inside `writing-plans`.

**What changes.** In `skills/subagent-driven-development/SKILL.md`, "The Task Loop" stops after slice
one of an architectural change. "Model Selection" keeps its tier definitions and reads the model from
the plan, and it reports a deviation. "Dispatch the implementer" dispatches independent slices in
parallel.

In `skills/executing-plans/SKILL.md`, "Step 2: Execute Tasks" stops after slice one of an architectural
change.

**How to demonstrate it.** Run an architectural change through the chain and watch the session stop
after slice one. Run a bounded change and watch it run to the end.

**What proves it.** The task briefs under the workspace that `scripts/sdd-workspace` creates name a
model for every task. Then the 18 SDD scenarios and the 4 test-craft scenarios run against the
baseline.

**The 4 test-craft scenarios must stay green.** `tdd-holds-under-tests-later-pressure` states that the
agent writes a test first after the human partner asks for the code first. Nothing in this plan changes
that behavior any more. A failure in any of the four is a defect in this change, not an expected
result, and it stops the slice.

## Slice 5 — the spec stays true and the pull request writes itself

Satisfies REQ-7, REQ-8.

**What changes.** A new `skills/reconciling-specs/SKILL.md`. It lists each divergence between `spec.md`
and the shipped change, asks for a ruling on each, writes the accepted rulings into `spec.md` with the
identifiers unchanged, and then invokes `finishing-a-development-branch`.

In `skills/finishing-a-development-branch/SKILL.md`, "Option 2: Push and Create PR" generates the body
from the reconciled spec. The body opens with a plain explanation, lists the requirement identifiers,
fills every section of the repository template, holds no placeholder, and goes to the human partner for
approval before the pull request opens. The template-filling step goes to a subagent on Sonnet, because
the sections and the source of each are both known by then.

**How to demonstrate it.** Take a branch whose build renamed something the spec names. Watch one
divergence get listed, rule on it, and watch `spec.md` change while its identifiers hold.

**What proves it.** A generated body that fills every section of `.github/PULL_REQUEST_TEMPLATE.md`,
holds no "TBD" and no "TODO", cites at least one identifier, and passes the vendored checker.

## Slice 6 — the repository says what it now is

Satisfies REQ-11, REQ-10.8, REQ-10.9, REQ-10.10, REQ-10.11.

**What changes.** `CLAUDE.md` describes the stages of this chain and the artifact of each. It states
that this fork does not submit changes upstream. It drops the contribution rules of
`obra/superpowers`, and keeps one problem for each pull request, no fabricated content, and evidence
before a claim. It states that a behavior change to a skill carries eval evidence from `evals/`.
`AGENTS.md` takes the same text.

The eval results from every slice collect into one record under the change directory.

**How to demonstrate it.** A reader of `CLAUDE.md` names the stages. `diff CLAUDE.md AGENTS.md` prints
nothing.

**What proves it.** `diff CLAUDE.md AGENTS.md`, `tests/claude-code/run-skill-tests.sh`, and
`bun run quorum check`.

The mirror into `AGENTS.md` and the three command runs go to a subagent on Sonnet. The `CLAUDE.md` text
does not.

## What this could break

**The always-on surface.** `hooks/session-start` injects `skills/using-superpowers/SKILL.md` and
nothing else. Slice 1 adds trigger text there. Every session on every harness pays for each sentence,
and an over-long bootstrap degrades every other skill's triggering.

**Skill triggering across harnesses.** The plugin ships to Codex, Cursor, Devin, Hermes, Kimi,
OpenCode and Pi. The per-harness directories hold only manifests and point at `skills/`, so no copy
needs an update. The triggering behavior of a rewritten description is still untested outside Claude.

**The contract between `writing-plans` and `subagent-driven-development`.** Slice 3 changes the plan
format and Slice 4 changes the reader. A plan written between them still parses, because the new
fields are additions.

**Work already in flight.** Any branch that holds a plan in the old format keeps working, because
Slice 4 reads the model when the plan names one and falls back to its own Model Selection section when
the plan does not.

## Risks, worst first

**R1. The interview reorder in Slice 1 weakens the approval gate.** The `<HARD-GATE>` block stops
implementation until the human partner approves. Moving the classification after the intent moves that
gate. If the gate lands after the classifier by accident, a spike can start coding with nothing
approved. This is now the worst risk in the change, because the reversal of FC-4 removed the one above
it.

**R2. The plan stage reads the volume rules as permission to skip.** Slice 3 tells `writing-plans` that
one test for each file is wrong and that a coverage-only test is wasted code. A reader that generalizes
from those two sentences arrives at "fewer tests is better", which is not the rule. The template has to
say what the risk assessment buys, which is concentration, not subtraction.

**R3. The bootstrap grows.** Slice 1 adds text to the one file that loads in every session. Two
sentences are affordable. A section is not.

**R4. Two new skills compete with the old ones for the same trigger.** `writing-specs` and
`brainstorming` both answer "I want to build something". A description that overlaps produces a coin
flip at trigger time. REQ-10.7 asks each description to state when not to use the skill, and that
sentence is what separates them.

**R5. The eval evidence is not reproducible for a teammate.** Under the FC-7 ruling the scenarios stay
as they are. The record under REQ-10.11 is the only place a reason for a failure exists.

**R6. `bun` and the harness cost money and time.** A live eval starts real agent command lines with
permissions disabled. Running all 33 affected scenarios after every slice is not affordable. Run the
scenarios that a slice touches, and run the full set once at Slice 6.

## What this plan ruled out

**A single skill that holds the interview, the intent and the spec.** The spec answers this under "One
skill or two". `brainstorming` is already 250 lines and it loads through the session start hook.

**Copying the shepherd skills into the plugin.** REQ-10.1 forbids a dependency on them, and their text
cites personal paths throughout. The method travels. The files do not.

**Editing the eval scenarios in `evals/`.** FC-7 ruled against it. The clone is gitignored, so an edit
there would leave no trace in this repository.

**Enforcement hooks that block a write when a stage is missing.** The spec lists this under Non-goals.
The chain persuades for now.

**Rewriting the Iron Law in `test-driven-development`.** Lars ruled for it and then reversed the
ruling. Over-testing is wasted code, and the answer to it is where the tests sit, not whether behavior
gets one. The whole test change now lives in `writing-plans`.

**Doing Slice 6 first.** The instruction files describe the chain, and describing a chain that does not
exist yet is how a document starts lying.
