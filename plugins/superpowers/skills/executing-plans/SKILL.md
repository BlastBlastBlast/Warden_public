---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute the slices in order, report when complete.
An architectural change stops once, after slice one, so your human partner can see
the shape of the work before the rest is built.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents (Claude Code, Codex CLI, Codex App, Copilot CLI, and Gemini CLI all qualify; see the per-platform tool refs in `../using-superpowers/references/`). If subagents are available, use superpowers:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Ensure an isolated workspace: use superpowers:using-git-worktrees to create one or verify the existing one
2. Read plan file
3. Review critically - identify any questions or concerns about the plan
4. If concerns: Raise them with your human partner before starting
5. If no concerns: Create todos for the plan items and proceed

### Step 2: Execute Slices

For each slice:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Run the slice's demonstration command
5. Mark as completed

**Stop after slice one of an architectural change.** When the plan came from a
spec, run slice one's demonstration command, show your human partner the
output, and wait for them to continue, redirect, or stop. Do not start slice two
on your own. Once they approve the direction, the remaining slices run without
pausing.

A bounded change has no spec and does not stop. Run it to the end.

### Step 3: Complete Development

After all slices complete and verified:

**If this change has a `spec.md`:**
- Announce: "I'm using the reconciling-specs skill to check the spec against what shipped."
- **REQUIRED SUB-SKILL:** Use superpowers:reconciling-specs
- It hands over to finishing-a-development-branch when the rulings are done

**If this change has no `spec.md`** (a bounded change went intent → plan):
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

Skipping the reconcile on a change that has a spec leaves the spec describing
software that does not exist. Check for the file — do not go from memory.

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent
