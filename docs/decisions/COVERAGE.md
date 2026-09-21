# Three-way coverage: shepherd · superpowers2 · here

Read as: who provides each capability today, and what is still missing from `claude_fresh`.

- **shepherd** = `~/dev/shepherd`
- **sp2** = `~/dev/superpowers2` (your fork, HEAD `e59a05c`)
- **here** = `~/dev/claude_2026/claude_fresh`

`✓` provides it · `~` partial · `—` absent

## What changed since the last pass

Your fork grew an intent-first change chain. It now covers eleven capabilities that were
shepherd-only, and it ships `skills/asd-ste100/scripts/ste-lint.py` — **byte-identical, 455 lines,
to shepherd's `lib/ste-lint.py`**. Dependency M1 from the gap analysis is resolved: the linter comes
with the plugin.

The split is now clean. **sp2 is the judgment layer** (skills that reason). **shepherd is the
enforcement layer** — it is the only one of the three with `agents/`, `commands/`, `rules/`,
`settings.json` or guard hooks. sp2 has none of those directories.

## A. The change chain

| Capability | shepherd | sp2 | here | Take from |
|---|:--:|:--:|:--:|---|
| Intent capture, interview | `capture-intent` + `/intent` | `brainstorming` (records intent, classifies, routes) | — | **decide** |
| Spec authoring, RFC 2119 | `author-spec` | `writing-specs` | — | **decide** |
| Spec review before code | `agents/spec-reviewer` | — | — | shepherd |
| Plan authoring | `author-plan` | `writing-plans` | — | **decide** |
| Execution loop | `implement-plan` + `agents/implementer` | `subagent-driven-development`, `executing-plans` | — | **decide** |
| Code review, fresh context | `review-change` + `agents/code-reviewer` | `requesting-code-review` | — | **decide** |
| Receiving review feedback | `receiving-review` | `receiving-code-review` | — | **decide** |
| **Spec reconcile after ship** | — | `reconciling-specs` | — | **sp2 only** |
| **Verification before "done"** | `agents/verifier` | `verification-before-completion` | prose in `CLAUDE.md` | sp2 + shepherd |
| Finish branch, integration options | `finish-branch` + `/finish` | `finishing-a-development-branch` | — | **decide** |
| Chain orchestration, resume | `/build` + `lib/chain-state.py` | — (skills self-route) | `skills/new-work` | **shepherd only** |
| Stage-order gate | `hooks/guard-stage-order.sh` | — | — | **shepherd only** |
| Plan-drift report | `hooks/plan-drift.sh` | — | — | **shepherd only** |
| Change-record layout | `rules/change-records.md` | convention inside skills | — | shepherd |

## B. Craft skills

| Capability | shepherd | sp2 | here | Take from |
|---|:--:|:--:|:--:|---|
| TDD | `test-driven-development` (52 ln) | `test-driven-development` (320 ln) | — | **decide** |
| Systematic debugging | `systematic-debugging` (77 ln) | `systematic-debugging` (283 ln) | — | **decide** |
| Skill/rule authoring | `writing-skills` (57 ln) + `rules/instruction-files.md` | `writing-skills` (679 ln) | `rules/skill-authoring.md` | **decide** |
| Brainstorming | `brainstorming` (44 ln) | `brainstorming` (299 ln) | — | **decide** |
| STE controlled language | `rules/response-style.md`, `rules/spec-language.md`, `lib/spec_language.py` | `asd-ste100` + `scripts/ste-lint.py` | `output-styles/plain-technical.md` | all three, different tiers |
| Parallel work | `/parallel` + `bin/wt` | `dispatching-parallel-agents`, `using-git-worktrees` | — | **decide** |
| Test-writing craft | `rules/tests.md` | — | — | shepherd |
| Model selection | `rules/model-selection.md` + per-agent `model:` | — | env caps in `settings.json` | shepherd |
| Research tiers and citation | ~ inside `writing-skills` | — | `rules/research.md` | **here only** |

## C. Enforcement — shepherd is the only source

| Capability | shepherd | sp2 | here |
|---|:--:|:--:|:--:|
| Secret write guard | `hooks/guard-secrets.sh` | — | — |
| Secret **read** guard via Bash | `hooks/guard-secrets-read.sh` | — | — |
| Destructive `curl \| sh` guard | `bin/claude-guard-destructive` | — | — |
| Subagent must name a model | `bin/claude-guard-agent-dispatch` | — | — |
| Existing-test edit guard | `hooks/guard-test-files.sh` | — | — |
| Protected-path guard | `hooks/guard-protected-paths.sh` | — | — |
| Config-drift report | `hooks/config-drift.sh` | — | — |
| Secret-path `permissions.deny` (14 globs) | `settings.json` | — | — |
| **Default-branch guard** | — | — | `hooks/guard-default-branch.sh` |
| Commit/PR attribution | `settings.json` (`""` form) | — | `settings.json` (`null` form) |
| Subagent depth/concurrency caps | — | — | `settings.json` `env` |
| Session-start context injection | — | `hooks/hooks.json` + `hooks/session-start` | — |

## D. Tooling and standalone skills — shepherd only

| Capability | shepherd | sp2 | here |
|---|:--:|:--:|:--:|
| Status line: context + plan limits | `bin/claude-statusline-limits`, `bin/claude-limits-refresh` | — | — |
| Session handoff across `/clear` | `handoff` + `bin/claude-handoff` | — | — |
| Skill promotion repo ↔ global | `bin/promote-skill` | — | — |
| Worktree lifecycle | `bin/wt` | `using-git-worktrees` (skill only) | — |
| Repo adoption + templates | `repo-adoption` + `templates/` | — | — |
| Written policy → skill | `/policy` | — | — |
| Inline review comments | `crit`, `crit-cli` | — | — |
| Model-release re-evaluation | `model-update` | — | — |
| Explainer artifacts | `eli5` | — | — |
| Frontend/product design | `design-taste-frontend`, `emil-design-eng`, `review-animations` | — | — |

## E. What is missing *here*, ranked

| # | Missing from `claude_fresh` | Source | Blocking? |
|---|---|---|---|
| 1 | `agents/` — 5 subagents with models set | shepherd | **Yes.** `implement-plan` and `review-change` dispatch to them by name. |
| 2 | `commands/` — 8 slash commands | shepherd | **Yes.** 26 references across imported skill bodies. |
| 3 | `rules/` — 6 rules, 4 path-scoped | shepherd | **Yes.** `instruction-files.md` supersedes our `skill-authoring.md`. |
| 4 | Guard hooks — 7 scripts + `hooks/lib/guardrails.sh` | shepherd | **Yes** for safety parity. |
| 5 | `lib/chain-state.py` + tests | shepherd | **Yes** if you keep `/build` and the stage gate. |
| 6 | `settings.json` secret denials and guard wiring | shepherd | **Yes.** Ours has 1 deny rule; shepherd's has 23. |
| 7 | `bin/` — statusline, handoff, wt, promote-skill | shepherd | No. Quality of life. |
| 8 | `templates/` | shepherd | No. Needed by `repo-adoption`. |
| 9 | `lib/ste-lint.py` | **sp2 ships it** | No longer missing — comes with the plugin. |
| 10 | `asd-ste100` skill | **sp2 ships it** | No longer missing. |
| 11 | `reconciling-specs`, `verification-before-completion` | **sp2 only** | No. Arrives with the plugin install. |

## F. The overlap that still needs a ruling

Eight capabilities exist in both shepherd and sp2. Both will be loaded at once after the plugin
install, with overlapping descriptions, which the Claude Code docs say makes auto-triggering less
reliable: *"If descriptions are vague or overlap, Claude may load the wrong skill or miss one that
would help."*

| Pair | shepherd | sp2 | Note |
|---|--:|--:|---|
| intent capture | `capture-intent` | `brainstorming` | sp2's is `You MUST use this before any creative work` — it will win on trigger strength |
| spec | `author-spec` | `writing-specs` | both RFC 2119, both controlled language |
| plan | `author-plan` | `writing-plans` | shepherd's names vertical slices |
| execute | `implement-plan` | `subagent-driven-development` | shepherd's stops after slice one |
| review | `review-change` | `requesting-code-review` | shepherd's writes `review.md` |
| receive review | `receiving-review` | `receiving-code-review` | same intent |
| finish | `finish-branch` | `finishing-a-development-branch` | same intent |
| TDD / debugging / skills / brainstorming | 4 short rewrites | 4 long originals | 2–3 lines in common each |

Shepherd's versions are 4–12× shorter and write to `docs/changes/<slug>/`. sp2's are longer and
carry more worked examples. They are not mergeable by concatenation — pick one per row.
