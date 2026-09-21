# Superpowers — Fork Guidelines

This is a fork of [obra/superpowers](https://github.com/obra/superpowers), adapted for our team.

**This fork does not submit changes upstream.** Do not open pull requests against
`obra/superpowers`, do not target a `dev` branch that belongs to that project, and do not shape a
change here to be acceptable there. Upstream's contribution rules governed upstream. They do not
govern this repository.

We still pull releases from upstream, so expect merge conflicts in skills we have rewritten. That
cost is accepted.

## The Change Chain

Work moves through committed artifacts. Each stage reads the one before it and writes the next, so
the commit history is the audit trail.

| # | Stage | Skill | Writes |
|---|---|---|---|
| 1 | Interview and intent | `brainstorming` | `intent.md` |
| 2 | Spec | `writing-specs` | `spec.md` |
| 3 | Plan | `writing-plans` | `plan.md` |
| 4 | Implement | `subagent-driven-development` or `executing-plans` | the diff and its tests |
| 5 | Review | `requesting-code-review` | findings |
| 6 | Reconcile | `reconciling-specs` | an updated `spec.md` |
| 7 | Finish | `finishing-a-development-branch` | the pull request |

One change gets one directory: `docs/superpowers/changes/<YYYY-MM>-<slug>/`.

**The chain scales down.** `brainstorming` interviews first, records an intent, and only then
classifies the work. A spike keeps its intent in the conversation and writes nothing. A bounded
change writes an intent and a plan. An architectural change runs the whole chain. A one-line fix
does not cost seven documents.

**Each stage commits its own artifact, and that commit is the approval.** An artifact that exists
but is not committed means the stage did not finish.

## Skill Changes Require Evaluation

Skills are not prose. They are code that shapes agent behavior, and the content is tuned.

**A behavior change to a skill carries eval evidence from the harness under `evals/`.** Record the
affected scenarios before the change and after it. For any scenario that goes from pass to fail, say
which it is: the scenario holds behavior we deliberately changed, or the change broke something.
Those two need different responses and only you can tell them apart.

Do not restructure a Red Flags table, a rationalization list, or the "your human partner" language
without evidence that the change is an improvement. That wording is tested, not stylistic.

Use `superpowers:writing-skills` to develop and test skill changes.

## Eval harness

Skill-behavior evals live in
[superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/), cloned into `evals/` —
see `evals/README.md` for setup. Quorum drives real sessions of Claude Code, Codex and other agent
CLIs, and judges skill compliance with an LLM verifier. Plugin-infrastructure tests live at `tests/`.

`bun run quorum check` is the static gate and it costs nothing. A live eval starts a real agent
command line with permissions disabled and it spends model credit. Run the scenarios a change
touches, not all of them, and run the full set once before the work lands.

Known state on Bun 1.4.2: `bun test` reports two failures in the harness's own unit suite. Both come
from a Bun behavior change and neither touches the eval path. We accept them.

## What Does Not Belong Here

**Third-party dependencies.** Superpowers is a zero-dependency plugin by design. If a change
requires an external tool or service, it belongs in its own plugin. Adding support for a new harness
is the exception.

**Anything that reaches outside the plugin.** A skill must work for a teammate who installs this
plugin and nothing else. No skill may reference a personal `~/.claude` rule, a personal library, or
a path outside the plugin directory. Guidance a skill needs gets vendored in, with its license.

**Unrelated changes bundled together.** One problem per pull request. Split them.

**Fabricated content.** Invented claims, made-up problem descriptions, or functionality that does
not exist. If you cannot point at the session, the error, or the experience that motivated a change,
do not make it.

## Evidence Before A Claim

Never report a check you did not run. "Tests pass" means you ran them and are showing the output. If
you could not run something, say which command and why — an unverifiable claim is worse than an open
question.

This is the same rule `superpowers:verification-before-completion` carries, and it applies to
contributors as much as to sessions.

## Understand The Project Before Changing It

Before proposing changes to skill design, workflow philosophy, or architecture, read the existing
skills. This project has a tested philosophy about skill design, agent behavior shaping, and
terminology. "Your human partner" is deliberate and not interchangeable with "the user".

## General

- Test on at least one harness and report the result
- Describe the problem you solved, not just what you changed
- `AGENTS.md` holds the same text as this file. Change both together.
