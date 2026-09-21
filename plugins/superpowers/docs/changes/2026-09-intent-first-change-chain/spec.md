# Spec: an intent-first change chain

Intent: `intent.md`. Date: 2026-09-18. Status: accepted.

## Summary

This change adds an intent stage to the superpowers chain and a reconcile stage at its end. It changes
how the chain writes specs, how it splits plans, how it chooses tests, and how it assigns models. It
serves Lars and the team that installs this fork.

The intent author chose route O3. The interview runs first. The interview produces an intent. The
human partner approves the intent. The classifier then runs on the approved intent and routes the work.

Each requirement names a skill as its actor, because a skill is the only thing this repository ships.
Two skills do not exist yet. This spec calls them `writing-specs` and `reconciling-specs`, and REQ-10.6
creates them.

## Requirements

Eleven top-level requirements exceed the limit of about ten. The intent names six independent problems
in one chain. A split would put the intent stage and the reconcile stage in different specs, and the
reconcile stage reads the document that the intent stage starts.

Prose in this repository uses American spelling. This spec follows it.

### Behavior

**REQ-1** The `brainstorming` skill MUST interview the human partner and record an intent before it
classifies the work.

- **REQ-1.1** The skill MUST start the interview when the prompt is empty. It MUST also start the
  interview when the prompt is vague.
- **REQ-1.2** The skill MUST ask one question in each message.
- **REQ-1.3** The skill MUST record the problem, the proposed outcome, the constraints, the exclusions,
  the measure of success, and the open questions.
- **REQ-1.4** The skill MUST get an explicit approval of the intent before it classifies the work.
- **REQ-1.5** The intent MUST NOT contain a capitalized RFC 2119 keyword. An intent states a problem.
  A spec states a contract.
- **REQ-1.6** The skill MUST propose the `<YYYY-MM>-<slug>` name at the end of the interview.
- **REQ-1.7** The human partner MUST approve that name.
- **REQ-1.8** The skill MUST present the intent in the conversation before it writes any file. REQ-2.10
  states when the intent becomes a file.

*Proof: a recorded session that starts from the message "let's make a react todo list" shows an
approved intent before any other document, and shows one question in each message.*

**REQ-2** The `brainstorming` skill MUST classify the work after the human partner approves the intent,
and MUST route the work by its class.

- **REQ-2.1** A spike MUST end with a reported recommendation.
- **REQ-2.2** The skill MUST NOT invoke `writing-specs` for a spike. It MUST NOT invoke `writing-plans`
  for a spike.
- **REQ-2.3** The skill MUST invoke `writing-plans` for a bounded change.
- **REQ-2.4** The skill MUST NOT invoke `writing-specs` for a bounded change.
- **REQ-2.5** The skill MUST invoke `writing-specs` for an architectural change.
- **REQ-2.6** The skill MUST raise the class when it finds hidden complexity.
- **REQ-2.7** The skill MUST NOT lower the class after it announces one.
- **REQ-2.8** The skill MUST state the class to the human partner before it routes the work.
- **REQ-2.9** The skill MUST accept an override of the class from the human partner.
- **REQ-2.10** The skill MUST write the approved intent to `intent.md` for a bounded change. It MUST
  also write the approved intent to `intent.md` for an architectural change.
- **REQ-2.11** The skill MUST NOT write `intent.md` for a spike. The intent for a spike stays in the
  conversation.
- **REQ-2.12** The skill MUST write `intent.md` after an upgrade of the class from a spike, and MUST
  use the intent that the conversation already holds.

*Proof: three recorded sessions, one for each class, each write the documents that their class allows
and no others, and each name the next skill out loud. A fourth session upgrades a spike and writes the
intent that the earlier interview produced.*

**REQ-3** The `writing-specs` skill MUST write `spec.md` as numbered requirements in ASD-STE100 prose.

- **REQ-3.1** Each requirement MUST carry one capitalized RFC 2119 keyword.
- **REQ-3.2** Each top-level requirement MUST carry an identifier of the form `REQ-n`, and each
  sub-requirement MUST carry an identifier of the form `REQ-n.m`.
- **REQ-3.3** The skill MUST NOT change an identifier that an earlier commit contains.
- **REQ-3.4** Each requirement MUST name the actor that carries the obligation.
- **REQ-3.5** Each top-level requirement MUST state what proves it.
- **REQ-3.6** The skill MUST report a contradiction between two constraints as a flagged concern.
- **REQ-3.7** The skill MUST NOT choose between two contradictory constraints.
- **REQ-3.8** The skill SHOULD write fewer than about ten top-level requirements. A spec that exceeds
  that count MUST state the reason.
- **REQ-3.9** The skill MUST get an approval of `spec.md`, and MUST then invoke `writing-plans`.

*Proof: the vendored checker from REQ-10.3 reports no hard violation on a generated spec, and a reader
finds a keyword, an identifier, an actor and a proof in every requirement of it.*

**REQ-4** The `writing-plans` skill MUST split the work into vertical slices.

- **REQ-4.1** Each slice MUST deliver behavior that a person can demonstrate from end to end.
- **REQ-4.2** The skill MUST order the slices, and slice one MUST be the smallest slice that shows the
  shape of the change.
- **REQ-4.3** Each slice MUST cite the requirement identifiers that it satisfies.
- **REQ-4.4** The skill MUST NOT group work by technical layer.
- **REQ-4.5** The skill MUST write a demonstration command for each slice.
- **REQ-4.6** The `subagent-driven-development` skill MUST stop after slice one of an architectural
  change, and MUST wait for the human partner. The `executing-plans` skill MUST do the same.
- **REQ-4.7** The two execution skills MUST NOT stop after slice one of a bounded change.

*Proof: a plan for a feature that crosses three layers puts one demonstrable path through all three
layers in slice one, and a recorded session stops there.*

**REQ-5** The `writing-plans` skill MUST record a risk assessment for each slice, and MUST size the
tests from that assessment.

- **REQ-5.1** The risk assessment MUST name where the change can fail, and MUST name what that failure
  costs.
- **REQ-5.2** The skill MUST concentrate the tests of a slice where the risk assessment names a cost.
- **REQ-5.3** The `test-driven-development` skill MUST keep the failing test first for new behavior.
- **REQ-5.4** The `test-driven-development` skill MUST keep the failing test first for a bug fix. The
  failing test proves the cause.
- **REQ-5.5** The `test-driven-development` skill MUST keep the Iron Law.
- **REQ-5.6** The `writing-plans` skill MUST NOT ask for one test for each file.
- **REQ-5.7** The `writing-plans` skill MUST NOT ask for one test for each function.
- **REQ-5.8** The `writing-plans` skill MUST NOT ask for a test that only raises coverage.
- **REQ-5.9** The `writing-plans` skill MUST NOT record "no test" for a slice that changes behavior.
  The exceptions in `test-driven-development` stay the only exceptions.

*Proof: a plan for a change to a payment path concentrates its tests at that boundary, and a plan for a
change that touches twelve files asks for fewer than twelve tests.*

**REQ-6** The `writing-plans` skill MUST name a model for each slice that a subagent implements, and
the dispatching skill MUST use the model that the plan names.

- **REQ-6.1** The plan MUST assign the cheap tier to a slice whose files, tests, approach and code the
  plan all state.
- **REQ-6.2** The plan MUST assign the standard tier to a slice that crosses files, or that works from
  prose alone.
- **REQ-6.3** The plan MUST NOT name a model for a stage that the session runs itself. The interview,
  the spec, the plan, the review and the reconcile all run on the session's own model.
- **REQ-6.4** The `subagent-driven-development` skill MUST name a model in every dispatch.
- **REQ-6.5** The `subagent-driven-development` skill MUST report a deviation from the model that the
  plan names.
- **REQ-6.6** The `subagent-driven-development` skill MUST dispatch independent slices in parallel.
- **REQ-6.7** An executor that finds its slice underspecified MUST stop and MUST report.
- **REQ-6.8** An executor MUST NOT change the plan.

*Proof: the task briefs under the workspace that `scripts/sdd-workspace` creates name a model for every
task, and each model matches the plan or carries a reported reason.*

**REQ-7** The `reconciling-specs` skill MUST compare `spec.md` to the shipped change before the chain
opens a pull request.

- **REQ-7.1** The skill MUST list each divergence between the spec and the shipped change.
- **REQ-7.2** The skill MUST ask the human partner to rule on each divergence. The two rulings are "the
  spec was wrong" and "the code is wrong".
- **REQ-7.3** The skill MUST write an accepted spec change into `spec.md`.
- **REQ-7.4** The skill MUST keep the identifiers that REQ-3.2 sets through that edit.
- **REQ-7.5** The skill MUST NOT change a requirement without a ruling.
- **REQ-7.6** The skill MUST run for a change that has a spec.
- **REQ-7.7** The skill MUST NOT run for a change that has no spec.
- **REQ-7.8** The skill MUST invoke `finishing-a-development-branch` when the rulings are complete.

*Proof: a change whose build renamed a public command produces one listed divergence, one recorded
ruling, and an updated `spec.md` that keeps its original identifiers.*

**REQ-8** The `finishing-a-development-branch` skill MUST generate the pull request body from the
reconciled spec.

- **REQ-8.1** The body MUST open with a plain explanation of what the change is.
- **REQ-8.2** That explanation MUST pass the checker from REQ-10.3.
- **REQ-8.3** The body MUST list the requirement identifiers that the change satisfies.
- **REQ-8.4** The body MUST fill every section of the repository pull request template when the
  repository has one.
- **REQ-8.5** The body MUST NOT contain a placeholder. "TBD" and "TODO" are placeholders.
- **REQ-8.6** The skill MUST present the generated body to the human partner for approval before it
  opens the pull request.
- **REQ-8.7** The skill MUST NOT ask the human partner to write the body.

*Proof: a generated body fills every section of `.github/PULL_REQUEST_TEMPLATE.md`, contains no
placeholder, cites at least one requirement identifier, and passes the checker.*

### Data

**REQ-9** The chain MUST hold the documents for one change in one change record directory.

- **REQ-9.1** The directory MUST take the path `docs/superpowers/changes/<YYYY-MM>-<slug>/`.
- **REQ-9.2** A human partner preference for a different path MUST override REQ-9.1.
- **REQ-9.3** The directory MUST hold `spec.md` when the class is architectural.
- **REQ-9.4** The directory MUST hold `plan.md` when the class is bounded. It MUST also hold `plan.md`
  when the class is architectural.
- **REQ-9.5** The chain MUST NOT create the directory for a spike.
- **REQ-9.6** The chain MUST create the directory when the directory is absent and the class is
  bounded or architectural.
- **REQ-9.7** Each stage MUST commit its own document in its own commit. That commit records the
  approval.

*Proof: a chain run in a repository with no `docs/` directory creates the path and commits each
document in a separate commit. A spike in the same repository creates no directory.*

### Operations

**REQ-10** Every asset that this change adds MUST ship inside the plugin, and MUST reach every
supported harness.

- **REQ-10.1** Each skill MUST NOT reference a path outside the plugin directory. A personal rules
  file, a personal library and the shepherd repository are all outside the plugin directory.
- **REQ-10.2** The plugin MUST carry the RFC 2119 guidance and the ASD-STE100 guidance that REQ-3
  needs.
- **REQ-10.3** The plugin MUST carry a checker that reports hard violations of the ASD-STE100 rules.
- **REQ-10.4** The plugin MUST carry the license and the attribution of each vendored asset.
- **REQ-10.5** The `using-superpowers` skill MUST route an empty prompt to `brainstorming`. It MUST
  also route a vague prompt to `brainstorming`.
- **REQ-10.6** The plugin MUST contain a `writing-specs` skill and a `reconciling-specs` skill.
- **REQ-10.7** Each new skill MUST carry a `description` that states when to use it and when not to
  use it.
- **REQ-10.8** The changed skills MUST pass the existing suite under `tests/`.
- **REQ-10.9** Each changed skill MUST reach the per-harness copies through the existing sync scripts.
- **REQ-10.10** The change MUST record the result of each affected eval scenario before the change and
  after the change.
- **REQ-10.11** The change MUST state, for each scenario that goes from pass to fail, whether the
  scenario holds the old behavior or the change broke something.

*Proof: a fresh clone on a machine with no `~/.claude` runs the chain from intent to pull request, a
search for `shepherd` and for `.claude/` across `skills/` returns nothing, and
`tests/claude-code/run-skill-tests.sh` passes.*

**REQ-11** The repository instruction files MUST describe this chain.

- **REQ-11.1** `CLAUDE.md` MUST describe the stages of this chain and the artifact that each stage
  writes.
- **REQ-11.2** `CLAUDE.md` MUST state that this fork does not submit changes to `obra/superpowers`.
- **REQ-11.3** `CLAUDE.md` MUST NOT present the contribution rules of `obra/superpowers` as the rules
  of this fork.
- **REQ-11.4** `CLAUDE.md` MUST keep the rules that still hold for this fork. One problem for each pull
  request, no fabricated content, and evidence before a claim are three of them.
- **REQ-11.5** `AGENTS.md` MUST hold the same text as `CLAUDE.md`.
- **REQ-11.6** `CLAUDE.md` MUST state that a behavior change to a skill carries eval evidence from the
  harness under `evals/`.

*Proof: a reader of `CLAUDE.md` names the stages and the artifact of each, `diff CLAUDE.md AGENTS.md`
reports no difference, and no sentence tells a contributor to target `dev`.*

## Non-goals

Proposing any of this to `obra/superpowers`. The intent excludes it.

Enforcement hooks that block a write after the chain skips a stage. The chain persuades. A gate that
fails closed is a separate change.

Migration of the documents under `docs/superpowers/specs/` and under `docs/superpowers/plans/`. The old
paths keep working and nothing reads them.

Automatic measurement of the four success measures in the intent. Lars reads them by hand after a
month.

A rewrite of `systematic-debugging`, `verification-before-completion`, `requesting-code-review` or
`receiving-code-review`. The intent asks for none.

A rewrite of the visual companion in `brainstorming`. It is orthogonal to the interview.

## Constraints applied

**Rules and area guides**

- `CLAUDE.md` and `AGENTS.md` at the repository root. The two files hold the same text. REQ-11 rewrites
  them, and FC-1 records the ruling that permits it.
- `.github/PULL_REQUEST_TEMPLATE.md`. REQ-8.4 points at it.
- `hooks/session-start`. It injects `skills/using-superpowers/SKILL.md` and nothing else. REQ-10.5
  depends on that fact.
- `scripts/sync-to-codex-plugin.sh`. REQ-10.9 points at it.
- The personal global `CLAUDE.md` and `rules/model-selection.md`. They govern this session, and they
  govern the documents in this change record. They MUST NOT govern the shipped plugin, because REQ-10.1
  forbids a dependency on a personal rules file. REQ-6 restates the model split inside the plugin for
  that reason.
- `rules/spec-language.md`. It is path scoped to `docs/changes/**` and it governs this document.

**Policy skills**

This repository has no domain. It holds skills, hooks and packaging scripts. It stores no personal
data, handles no money, and authenticates no one. A policy skill has nothing to constrain here. The
absence matches the repository and it is not a finding.

## Flagged concerns

**FC-1 — the repository rules forbid this change. Ruled.**

`CLAUDE.md` states that personal workflow configuration does not belong in core, and that a
restructure of skill content is not accepted without eval evidence. The intent states that this fork
serves Lars and his team, and that upstreaming is out of scope.

Lars ruled on 2026-09-18. The root `CLAUDE.md` is upstream text that no longer governs this fork.
REQ-11 rewrites it. The pull request for this change targets the fork's own default branch.

**FC-2 — skill changes need eval evidence, and the eval harness was absent. Ruled.**

`CLAUDE.md` requires before and after eval results for a skill change. The harness lives in
`superpowers-evals`. That directory did not exist in this checkout.

Lars ruled on 2026-09-18. The harness is now cloned into `evals/`, which `.gitignore` already excludes.
A behavior change to a skill carries eval evidence from that harness. REQ-11.6 records the bar, and
REQ-10.10 and REQ-10.11 make it checkable.

The state of the harness on 2026-09-18. `bun run quorum check` passes and it checks 96 scenarios.
`bun test` reports 3972 passes and 2 failures. Both failures come from Bun 1.4.2, and neither one
touches the eval path. `package.json` sets the floor at `>=1.3.13` and sets no ceiling. The first
failure assigns `undefined` to `process.env.PATH`, which Bun 1.4.2 stores as the string "undefined",
so the fallback at `src/checks/index.ts:116` never runs. The second failure expects a native server
handle to hold the event loop open.

A live eval starts a real agent command line with permissions disabled and it spends model credit.

**FC-3 — an intent on every path costs a document that the scale-down constraint forbids. Ruled.**

REQ-1.1 starts the interview for any vague prompt. The intent constrains the chain to scale down, and
says that a one-line fix must not cost six documents.

Lars ruled on 2026-09-18. The interview and the intent happen on every path. The intent for a spike
stays in the conversation. REQ-2.10, REQ-2.11 and REQ-9.5 carry the ruling. REQ-2.12 covers the case
where the class was wrong, because an upgrade from a spike writes the intent that the conversation
already holds.

**FC-4 — REQ-5 overrode the Iron Law in `test-driven-development`. Ruled, and then reversed.**

`skills/test-driven-development/SKILL.md` states "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST". It
lists refactoring and behavior changes under "Always". It admits three exceptions, and each one asks
the human partner first. REQ-5.2 lets a plan record "no test" for a slice without that question.

Lars ruled on 2026-09-18, and then reversed that ruling on the same day. The Iron Law stays. REQ-5.5
keeps it and REQ-5.9 keeps its exceptions as the only exceptions.

The complaint in the intent is about volume, not about test-first. REQ-5.2, REQ-5.6, REQ-5.7 and
REQ-5.8 answer the volume. A test that only raises coverage is wasted code, and the risk assessment is
what stops the plan from asking for one.

No conflict remains between REQ-5 and `test-driven-development`.

**FC-5 — REQ-4.6 overrides the autonomy of the execution skills. Ruled.**

`skills/executing-plans/SKILL.md` says to execute all tasks and report when complete.
`skills/subagent-driven-development/SKILL.md` runs a task loop without a stop.

Lars ruled on 2026-09-18. The stop after slice one applies to an architectural change only. REQ-4.6 and
REQ-4.7 carry the ruling. A bounded change runs to the end as it does today.

**FC-6 — REQ-6 and `subagent-driven-development` disagree on the tier of a prose-only slice. Ruled.**

`skills/subagent-driven-development/SKILL.md` sets a mid tier as the floor for an implementer that
works from a prose description. It gives the cheapest tier only to a task whose plan text contains the
complete code.

Lars ruled on 2026-09-18 and he accepts that reading. REQ-6.1 and REQ-6.2 already state it. A cheap
model takes more turns on prose work, and the extra turns cost more than the cheaper tokens save.

**FC-7 — the evidence for this change lives in a repository that this change cannot commit to. Ruled.**

The harness holds 96 scenarios. 33 of them exercise behavior that this spec changes. 18 cover
`subagent-driven-development`, 4 cover `brainstorming`, 4 cover the test craft, and 3 cover spec
authoring.

The reversal of FC-4 removes most of this risk. The scenario `tdd-holds-under-tests-later-pressure`
states that the agent writes the test first after the human partner asks for the code first. REQ-5.5
keeps the rule that produces that behavior, so the scenario keeps its meaning.

A scenario that holds the old behavior needs an edit. Those scenarios live in `superpowers-evals`,
which is a separate repository. `.gitignore` excludes `evals/`, so no commit in this change can carry
that edit.

Lars ruled on 2026-09-18. A scenario that holds the old behavior fails, and this change does not edit
it. REQ-10.11 records each failure with the reason. This change opens no matching change in
`superpowers-evals`.

Lars also accepts the two `bun test` failures that Bun 1.4.2 causes. `bun run quorum check` stays the
gate for this change.

## Open questions carried from intent

**Where the classifier runs.** Answered. REQ-1 and REQ-2 put the interview and the intent before the
classifier. This is route O3.

**One skill or two.** Answered. REQ-1 and REQ-2 give the interview, the intent and the classification
to `brainstorming`. REQ-10.6 creates `writing-specs` for the spec stage. The `brainstorming` skill is
already 250 lines, and the session start hook makes the always-on surface expensive.

**Where the documents live.** Answered by REQ-9.1, and REQ-9.2 makes it reversible. The path stays
inside the `docs/superpowers/` namespace that the plugin already uses. This change record sits at
`docs/changes/` because the chain that wrote it is the old one.

**Whether reconcile is its own stage.** Answered. REQ-7 and REQ-10.6 make it a skill of its own that
runs before the finish stage.

**What decides a test's risk profile.** Answered by REQ-5.1 and REQ-5.2. The plan stage decides where
the tests concentrate. It does not decide whether behavior gets a test, because REQ-5.5 keeps the Iron
Law.

**Where the model policy lives.** Answered by REQ-6. The plan records the model only for a slice that a
subagent implements. Every other stage runs on the session's own model. The Model Selection section of
`subagent-driven-development` keeps the tier definitions, and FC-6 records the reading.

**The smallest change that earns an intent.** Answered by the FC-3 ruling. Every change earns an
interview and an intent. A spike keeps that intent in the conversation, so the smallest change that
earns an `intent.md` file is a bounded change.

## Design notes

The chain gains two stages and keeps its shape.

| Stage | Skill before | Skill after |
|---|---|---|
| Interview | `brainstorming`, classify first | `brainstorming`, interview first |
| Intent | absent | `brainstorming` writes `intent.md` |
| Classify | before the interview | after the intent |
| Spec | a design document in prose | `writing-specs` writes `spec.md` |
| Plan | `writing-plans`, horizontal tasks | `writing-plans`, vertical slices |
| Implement | `subagent-driven-development` | unchanged, and it reads the model from the plan |
| Review | `requesting-code-review` | unchanged |
| Reconcile | absent | `reconciling-specs` |
| Finish | `finishing-a-development-branch` | unchanged, and it generates the body |

The session start hook injects `skills/using-superpowers/SKILL.md` and nothing else. Any behavior that
must fire before the first response belongs in that file. REQ-10.5 depends on this.

The `brainstorming` skill states that the only skill it invokes after itself is `writing-plans`.
REQ-2.5 breaks that statement, and the implementation must edit it.

The `writing-plans` skill states that a task is "the smallest unit that carries its own test cycle".
REQ-4.1 replaces that unit with a slice. The two sections that hold the old unit are "File Structure"
and "Task Right-Sizing".

The `test-driven-development` skill holds the Iron Law under that heading, and a "When to Use" section
that lists four cases under "Always". REQ-5.9 changes both. The red-green-refactor cycle below them
stays, because REQ-5.4 keeps the failing test first wherever the plan calls for a test.
