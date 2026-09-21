# Shepherd import and gap analysis

## 1. What was imported

20 skills from `~/dev/shepherd/skills` into `claude_fresh/skills/`, plus the `new-work` skill this
repo already had. 21 total.

```
author-plan   author-spec    brainstorming  capture-intent  crit         crit-cli
design-taste-frontend        eli5           emil-design-eng finish-branch
handoff       implement-plan model-update   receiving-review repo-adoption
review-animations            review-change  systematic-debugging
test-driven-development      writing-skills
```

Excluded, with reasons:

| Excluded | Reason |
|---|---|
| `asd-ste100` | Byte-identical to `superpowers2/skills/asd-ste100`. It is a vendored copy, so it comes from the fork instead. |
| `skills/synced/` | A claude.ai sync bucket keyed by account UUID. Machine state, not a skill. |
| `skills/.trash/` | Deleted skills. |

**The other four name collisions are not copies.** `brainstorming`, `systematic-debugging`,
`test-driven-development` and `writing-skills` exist in both repos, but shepherd's are independent
rewrites, not forks — 44 vs 299 lines, 77 vs 283, 52 vs 320, 57 vs 679, with 2 to 3 lines in common
each. Shepherd's versions were imported. See decision **D1**.

## 2. The superpowers swap

The installed plugin is upstream, not your fork:

```
superpowers@claude-plugins-official  6.3.0  scope: user
installed 2026-06-09, from anthropics/claude-plugins-official
```

Your fork declares marketplace `superpowers-dev` and plugin `superpowers` at version 6.3.0. Both
plugins are named `superpowers`, so the old one has to go before the new one lands.

**This also settles the open question from the last two rounds: there is no `/superpowers` command.**
`superpowers2` has no `commands/` directory and no user-invocable skill. The plugin enters through a
`SessionStart` hook and through skill descriptions that fire on their own — `using-superpowers`
says "use when starting any conversation", `brainstorming` says "You MUST use this before any
creative work". `skills/new-work/SKILL.md` said "Run `/superpowers`", which would have done nothing.
It now routes to `/build` and records that the command does not exist.

## 3. The imported skills are not standalone

The 20 skills reference machinery that did not come with them. Nothing here works until these land.

| # | Missing | Needed by |
|---|---|---|
| **M1** | `~/.claude/lib/ste-lint.py` | `author-plan`, `author-spec` (in `allowed-tools`, so the call is pre-approved and then fails) |
| **M2** | Subagents `implementer`, `verifier`, `code-reviewer`, `spec-reviewer` | `implement-plan`, `review-change`, `author-plan` |
| **M3** | Commands `/build`, `/intent`, `/spec`, `/review`, `/policy` | 9 references to `/spec`, 7 to `/intent`, 6 to `/review`, 2 to `/build`, 2 to `/policy` across the skill bodies |
| **M4** | `~/.claude/lib/chain-state.py` | shepherd's `permissions.allow`, and the stage-order hook |
| **M5** | Binaries `crit`, `claude-handoff`, `wt` | `crit`, `crit-cli`, `handoff` |

Shepherd is a system, not a bag of skills. The chain skills (`capture-intent` → `author-spec` →
`author-plan` → `implement-plan` → `review-change` → `finish-branch`) only function with M1–M4.
The standalone ones that work today are `eli5`, `design-taste-frontend`, `emil-design-eng`,
`review-animations`, `model-update`, `brainstorming`, `systematic-debugging`,
`test-driven-development`, `receiving-review`, `writing-skills`.

## 4. Gap analysis — shepherd's non-skill assets

### Hooks (`shepherd/hooks/`, `shepherd/bin/`)

| # | Asset | What it does | Verdict |
|---|---|---|---|
| **H1** | `guard-secrets-read.sh` | PreToolUse(Bash): denies shell reads of `.env` and key files. Written because `permissions.deny` on Read is not extended to every Bash command — measured against 2.1.270, `cat .env` is blocked but `head -1 .env` returns the secret. | **Adopt.** Closes a hole the settings file cannot. |
| **H2** | `guard-secrets.sh` | PreToolUse(Write\|Edit): denies a write carrying a high-confidence secret shape. Three shapes only, names the shape and never the value. | **Adopt.** |
| **H3** | `claude-guard-destructive` | PreToolUse(Bash): blocks curl/wget piped into a shell, in its common forms, which a static glob cannot match. | **Adopt.** |
| **H4** | `guard-test-files.sh` | PreToolUse(Write\|Edit): asks before editing a test that already exists; a new test never prompts; an edit whose `old_string` survives inside `new_string` is growth, not weakening, and passes. | **Adopt.** Enforces "test first" deterministically. |
| **H5** | `claude-guard-agent-dispatch` | PreToolUse(Agent): a generic dispatch must set `model` explicitly, so mechanical work does not silently run on the session's expensive model. | **Adopt.** Pairs with `rules/model-selection.md`. |
| **H6** | `plan-drift.sh` | Stop: reports when the working tree touches files `plan.md` does not name. Advisory, and guards its own re-entry so the report does not repeat on every Stop. | **Adopt with M3.** Needs the chain. |
| **H7** | `guard-stage-order.sh` | PreToolUse(Write\|Edit): denies writing a stage artifact before the previous stage finished. | **Adopt with M3/M4.** |
| **H8** | `ste-lint-spec.sh` | PostToolUse(Write\|Edit): lints SDLC docs, advisory via exit 2. | **Adopt with M1.** |
| **H9** | `config-drift.sh` | Stop: reports when live `settings.json` drifts from its committed state, because Claude Code rewrites that file at runtime and a long session can revert it. | **Adopt.** Non-obvious failure mode, worth keeping. |
| **H10** | `guard-protected-paths.sh` | PreToolUse(Write\|Edit): denies edits to paths a project declares in `protectedPaths`. No-ops when undeclared. | **Adopt.** |
| **H11** | `.orca/agent-hooks` blob on 8 events | Third-party (Orca) injection, base64 PowerShell inside a shell `case`. Not shepherd's. | **Strip.** Do not carry it into the new settings file. |

### Rules (`shepherd/rules/`)

| # | Rule | Scope | Verdict |
|---|---|---|---|
| **R1** | `instruction-files.md` | `CLAUDE.md`, `AGENTS.md`, `SKILL.md`, rules, settings | **Adopt, supersedes ours.** Same tiering conclusion as `ARCHITECTURE.md`, already path-scoped, already written. |
| **R2** | `spec-language.md` | spec/plan/ADR paths | **Adopt.** RFC 2119 contract discipline. |
| **R3** | `change-records.md` | `docs/changes/**` | **Adopt with M3.** |
| **R4** | `tests.md` | test file globs | **Adopt.** |
| **R5** | `model-selection.md` | unscoped | **Adopt.** Opus to plan, Sonnet to execute a fully specified task. Pairs with H5 and the agent models. |
| **R6** | `response-style.md` | unscoped | **Conflict.** See D2. |

### Agents, commands, lib, templates

| # | Asset | Verdict |
|---|---|---|
| **A1** | 5 subagents with models set (`implementer`=sonnet, `researcher`=haiku, reviewers=opus) | **Adopt.** Required by M2, and the model split is the cost control. |
| **A2** | 8 commands (`/build` `/intent` `/spec` `/review` `/finish` `/adopt` `/parallel` `/policy`) | **Adopt.** Required by M3. `/build` is the real chain entry. |
| **A3** | `lib/ste-lint.py`, `lib/spec_language.py`, `lib/chain-state.py` + their tests | **Adopt.** Required by M1 and M4. |
| **A4** | `bin/claude-statusline-limits` | **Adopt.** Context window plus plan limits in the status line — the "track context continuously" best practice, already built. |
| **A5** | `bin/promote-skill`, `bin/wt` | **Adopt.** Worktree and skill-promotion tooling. |
| **A6** | `templates/` (project CLAUDE.md, guardrails, evals, GH workflow, policy skill) | **Adopt with `repo-adoption`.** |
| **A7** | `shell/` (zshrc, sheldon, kubectl, macos) | **Skip.** Shell config, not Claude setup. |

## 5. Conflicts with what we built in rounds 1 and 2

| # | Ours | Shepherd's | Recommendation |
|---|---|---|---|
| **C1** | `output-styles/plain-technical.md` | `rules/response-style.md` + superpowers2 `asd-ste100` skill | Three writing-style surfaces. See **D2**. |
| **C2** | `rules/skill-authoring.md` | `rules/instruction-files.md` + `skills/writing-skills` | Drop ours. Shepherd's is path-scoped and covers more. |
| **C3** | `rules/research.md` | research and citation guidance inside `skills/writing-skills` | Keep ours. It applies to every answer; shepherd's fires only when editing instruction files. |
| **C4** | `skills/new-work` | `commands/build.md` + `capture-intent` description | See **D3**. |
| **C5** | `hooks/guard-default-branch.sh` | nothing equivalent | **Keep ours.** Shepherd has no branch guard. This is a real gap we filled. |
| **C6** | `attribution: {commit: null, pr: null}` | `attribution: {commit: "", pr: ""}` | Shepherd's empty strings are the in-use, proven form. Take shepherd's. |
| **C7** | `permissions.deny: Bash(gh pr merge:*)` | `Bash(gh pr merge*)`, plus `Bash(git push -f*)`, `Bash(sudo*)`, `Bash(rm -rf /*)` and 14 secret-path Read denials | Take shepherd's list. **But check one rule:** under plain glob semantics `Bash(git push -f*)` cannot match `git push --force`, since the pattern needs `f` where the command has a second `-`. If that holds for Claude Code's Bash matcher, the `--force` long form is unguarded today. Confirm with `/permissions`, then add a literal rule for `--force` kept distinct from `--force-with-lease`. |

## 6. Decisions I need from you

**D1 — the four rewritten skills.** `brainstorming`, `systematic-debugging`,
`test-driven-development` and `writing-skills` now exist twice: shepherd's short version and the
fork's long one. Plugin skills are namespaced (`/superpowers:brainstorming`), so there is no hard
collision, but overlapping descriptions make auto-triggering less reliable. Your current global
CLAUDE.md already says shepherd's win. Confirm that still holds, or say which should come from the
fork.

**D2 — writing style, three surfaces.** Ours is an output style (system prompt, every turn),
shepherd's is an unscoped rule (user message, every turn), the fork's is a model-invoked skill.
They agree on substance. My recommendation: keep the output style as the single always-on surface,
fold anything from `response-style.md` it lacks into it, and leave the fork's skill for on-demand
rewrites of someone else's text.

**D3 — `new-work` versus `/build`.** `capture-intent` already auto-triggers on "someone describes a
problem, a feature idea, a complaint", and `/build` is the chain entry. `new-work` now adds only the
small-versus-big boundary test. My recommendation: delete `new-work` and move its size test into
`/build`, which is where the chain already decides whether to run.

**D4 — how much of shepherd to take.** Sections 3 and 4 say the chain skills need M1 to M4 to run at
all. The honest options are: take the whole system (hooks, rules, agents, commands, lib, templates),
or take only the 10 standalone skills and drop the chain. A half import leaves pre-approved tool
calls pointing at scripts that are not there.
