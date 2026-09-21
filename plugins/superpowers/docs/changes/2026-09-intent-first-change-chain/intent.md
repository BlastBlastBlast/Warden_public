# Intent: an intent-first change chain

Author: Lars. Date: 2026-09-18. Status: accepted.

## Problem

Superpowers is the better tool and its chain stays. Six things in it do not hold up in daily use.

There is no intent stage. Brainstorming interviews well, then goes straight to a spec, so the goal is
never written down apart from the requirements. Nobody can check later whether the requirements
answered the goal. Brainstorming also writes nothing at all unless it classifies the work as
architectural, so a vague request can produce code with no recorded goal.

Specs are written as ordinary prose. Without RFC 2119 obligation levels and ASD-STE100 controlled
language they read differently to two people, and differently again to an agent.

Plans build horizontally. A full layer is finished before anything can be run, so the first honest
review of the work arrives an hour or two in.

The spec goes stale during the build and is discarded at the end, so no durable description of the
system survives the change that created it.

Test-driven development writes tests across the whole surface rather than where risk sits, so volume
grows without signal.

The plan records no model for a task. Subagent-driven development already says which tier suits which
kind of work, but it derives the choice at dispatch time from a plan that never stated it, so there is
nothing to check the choice against.

This is a pattern across Lars's use of the plugin, not one recorded incident.

## Proposed outcome

The interview stays, because it is the part that works. One interview now serves two outputs. It
produces a short, goal-oriented intent first. Lars agrees to that intent. Only then does the same
understanding become a technical spec. A vague or empty prompt starts this interview, whatever the
size of the work turns out to be.

A spec reads as numbered obligations, written to RFC 2119 obligation levels in ASD-STE100 controlled
language. A teammate and an agent parse it the same way.

The first slice of a change is demonstrable end to end early, so feedback lands while the shape can
still change.

Tests are chosen where risk concentrates, and "no test here" is an answer the process can give.

At pull request time the spec still describes the shipped system. Divergences are surfaced as
decisions, the accepted ones are written back into the spec, and the pull request body is generated
from the reconciled spec in the same controlled language, opening with a plain explanation of what the
change is.

The plan names the model for each unit of work. The orchestrating session is the most capable model,
usually Opus. Fully specified implementation runs on Sonnet subagents, and there are many of them.
The dispatch follows what the plan already decided.

## Affected users and systems

Lars, and the team that will install this fork.

Every skill in the fork is in scope. The ones this is known to reach are using-superpowers,
brainstorming, writing-plans, executing-plans, subagent-driven-development, test-driven-development,
finishing-a-development-branch, and whichever skill ends up owning reconcile and the pull request
body. No skill is protected from change.

Shepherd, which is being retired. Its assets may be read as reference material while this work is
authored. Nothing in the fork may depend on shepherd at run time.

## Constraints

A teammate installs this plugin on its own. No skill may reference shepherd, a personal `~/.claude`
rule, or a script outside the plugin.

Skills must keep auto-triggering. A chain that only runs when a slash command is typed will not run.

The chain must scale down. A one-line fix must not cost six documents.

Rewriting existing upstream skill files is accepted, and so is the merge cost of every later
obra/superpowers release.

The interview is kept. Whatever else changes in brainstorming, the entry point stays a conversation
that asks one question at a time, and `/brainstorming` stays the command that starts it.

## Out of scope

Proposing any of this to obra/superpowers. This fork serves Lars and his team.

Porting shepherd wholesale. Only the capabilities named above.

Deciding what belongs outside the plugin, in a CLAUDE.md or a rules directory. That gap analysis comes
after this change, once the fork stands on its own.

## How we will know it worked

The spec still describes the shipped system at pull request time, with few drift items to reconcile.

Feedback arrives at slice one, rather than after every layer is built.

Fewer tests are written per change, none of them are later deleted as useless, and bugs are still
caught.

A teammate understands what a pull request does and why from its body alone, with no verbal
walkthrough.

Read these a month after the team is working in the fork.

## Open questions

Brainstorming classifies work as spike, bounded or architectural, and only the architectural path
writes anything to disk. An intent on every vague prompt does not fit that classifier. Does the
classifier move after the intent, does it lose a path, or does the intent get written on every path?

Does one skill hold the whole interview and both documents, or does brainstorming hand over to a
second skill after the intent is agreed?

Where do intent and spec documents live inside a target repository, and what creates that directory on
a repository that has never run the chain?

Is reconcile its own stage, or the opening of the finish stage?

What decides a test's risk profile, and at which stage is "no test" allowed to be the answer?

Where is the model policy recorded, given that subagent-driven development already carries one, and
what is the rule for a task whose specification turns out to be incomplete?

How far down does the chain scale? What is the smallest change that still earns an intent?
