# Accounting: every line of the original CLAUDE.md

The original is `claude_2026/claude_fresh/CLAUDE.md`, 93 lines, written before anything was moved to
a cheaper tier. This checks that each item still exists somewhere in the Warden setup.

Verified 2026-09-20 against the live files, not from memory.

## Accounted for

| # | Original | Lines | Now lives in |
|---|---|---|---|
| 1 | Repo `CLAUDE.md`/`AGENTS.md` beats this file | 3 | `CLAUDE.md` line 3 |
| 2 | Never edit on the default branch, branch first | 7, 10 | `CLAUDE.md` Git, restored as an absolute |
| 3 | Branch prefixes, kebab-case | 9 | `CLAUDE.md` Git |
| 4 | Conventional commits | 11 | `CLAUDE.md` Git |
| 5 | **No AI attribution** | 12 | `settings.json` → `attribution: {commit:"", pr:"", sessionUrl:false}`. Config, not prose. |
| 6 | Rebase, never merge in | 13 | `CLAUDE.md` Git |
| 7 | `--force-with-lease` only | 14 | `CLAUDE.md` Git, strengthened with "never plain `--force`" |
| 8 | Do not merge PRs, hand the command over | 15 | `CLAUDE.md` Git — **prose only**, see G2 |
| 9 | Command handoff, all six bullets | 17–29 | `CLAUDE.md`, verbatim |
| 10 | Reads/edits/tests/builds are yours | 29 | `CLAUDE.md`, verbatim |
| 11 | **Start the spec workflow on build/create/make** | 31–34 | superpowers `brainstorming` — `You MUST use this before any creative work` |
| 12 | **Skip it for small work** | 36–39 | superpowers `brainstorming` Three Paths: Bounded goes straight to a plan, Architectural gets a spec. Stronger than the original — it also names the rationalisations that talk you out of the heavier path. |
| 13 | Reuse: search, extend, say what you reused | 43–45 | `CLAUDE.md` Reuse |
| 14 | **Match the surrounding code** | 46 | Claude Code's own system prompt: *"Write code that reads like the surrounding code: match its comment density, naming, and idiom."* Dropped as duplication. |
| 15 | Twice is a pattern → extract | 47 | `CLAUDE.md` Reuse |
| 16 | Make a skill the second time | 51 | `CLAUDE.md` "Turn a repeated job into a skill" |
| 17 | **Skill locations, description-as-trigger, `disable-model-invocation`** | 53–56 | `rules/instruction-files.md` — path-scoped to `**/SKILL.md`, so it loads only when authoring one |
| 18 | **Scope: no adjacent improvement, minimum code, every line traces to the ask** | 61–68 | Claude Code's system prompt carries scope control on Opus 5. Dropped as duplication — see `RESEARCH.md` §2. |
| 19 | Verification, all four bullets | 72–75 | `CLAUDE.md` Verification |
| 20 | Research before you set direction | 79–80 | `CLAUDE.md` "Research before you answer" |
| 21 | **Source tiers and citation format** | 82 | `skills/source-authority/SKILL.md` |
| 22 | **Writing style, one idea per sentence** | 86–88 | `output-styles/plain-technical.md`, active via `outputStyle`. System-prompt tier, so it binds harder than the original prose did. |
| 23 | Twice is a pattern → write it into the repo's `CLAUDE.md` | 91–93 | `CLAUDE.md`, restored |

## Gaps that remain

**G1 — resolved 2026-09-23: the guard is wired** (`OPUS-5-5-EVALUATION.md`, E23). Earlier text:
the branch rule is stated, not enforced. `hooks/guard-default-branch.sh` exists, is tested,
and is **not wired**. Item 2 is therefore a request rather than a guarantee. Wire it under
`PreToolUse` with matcher `Write|Edit|NotebookEdit`, or leave it as prose deliberately.

**G2 — resolved 2026-09-23 for merges and force pushes** (`OPUS-5-5-EVALUATION.md`, E22):
`Bash(gh pr merge *)` and six `git push` force shapes are denied; `--force-with-lease` is not.
`sudo` and `rm -rf ~` stay open. Earlier text: no git denials in `permissions`. The original relied on prose for "do not merge PRs". The
pruning pass that cut the guard hooks also removed every `Bash(...)` deny rule, including
`Bash(gh pr merge*)`, `Bash(git push -f*)`, `Bash(sudo*)` and `Bash(rm -rf ~*)`. Those are static
config with zero context cost and no effect until they fire — a different thing from a blocking
hook. Restoring them is one line each.

## Two things repaired during this audit

- `CLAUDE.md` pointed at `rules/skill-authoring.md`, which no longer exists — it was merged into
  `rules/instruction-files.md`. A dangling pointer in an always-loaded file.
- "Twice is a pattern" had been dropped on the grounds that auto memory covers it. It does not:
  auto memory is machine-local and private, while the original rule is about committing the fix
  into the repo where the team reads it. Restored.
