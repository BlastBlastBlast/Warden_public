# Warden setup vs. Opus 5.5 — evaluation

Compiled 2026-09-23. Compares `~/dev/Warden` (live as `~/.claude` via symlinks) against
`~/dev/opus5.5-claude-md-reference.md` (codes R#, A#, C#, D#, S#) and the Opus 5 baseline
`~/dev/opus5-claude-md-ruleset.md`. Nothing was changed. Claude Code version: 2.1.280.

Verdicts: **KEEP** · **EDIT** · **REMOVE** · **MOVE** · **ADD** · **DECIDE** (your call).
"Driver" says whether Opus 5.5 causes the finding, or whether it comes from the Opus 5 baseline
or from structure unrelated to the model.

## Summary

- No surface contains the Opus 5.5 DELETE patterns R1–R5: no "think carefully", no forced
  reasoning in the reply, no no-thinking rules, no vision workarounds.
- Most of the global CLAUDE.md is process, and Opus 5.5 leaves process alone. It also already
  names the stops you want, which the Opus 5.5 blog recommends.
- The largest problem is carried over from Opus 5: the emphatic superpowers injection (E31).
- One config entry is inert on Opus 5.5 (E17).

## Table

| # | Surface | Item | Verdict | Driver | Reason |
|---|---|---|---|---|---|
| E1 | CLAUDE.md · Git | Branch first, prefixes, conventional commits, rebase, `--force-with-lease` | KEEP | — | Process. No Opus 5.5 source touches it. |
| E2 | CLAUDE.md · Git | "Do not merge pull requests. Stop at an open PR with green CI and hand me the command." | KEEP | A1 | A named stop. The blog says "Name the stops you want, too." |
| E3 | CLAUDE.md · Command handoff | All six bullets + "Reads, edits, tests… are yours" | KEEP | A1 | Matches the stops Anthropic keeps: "where nothing can move without them". |
| E4 | CLAUDE.md · Reuse | "Search before you write…" | KEEP | A6 | Opus 5.5 "tends to get to work quickly"; exploring first still helps. |
| E5 | CLAUDE.md · Reuse | "If you found nothing, say what you searched for." | KEEP | A3 | Same idea as the blog's "say where you looked". |
| E6 | CLAUDE.md · Verification | Test first; pass/fail check; "Never claim a pass you did not see" | KEEP | D3 | Evidence from a run, not self-re-checking. System card: top flagged behavior is "asserting unverified inferences as established fact". |
| E7 | CLAUDE.md · Research | "Check current practice… anything about Claude or Anthropic" | KEEP | — | Proved its value today: the stale `llms.txt` made one agent claim Opus 5.5 did not exist. |
| E8 | CLAUDE.md · Skills / Twice is a pattern | Both sections | KEEP | — | Process. |
| E9 | CLAUDE.md · (missing) | Keep-going rule: "When a step doesn't need my input, keep going. Put status notes in the same message as your next action." | DECIDE | A1 | The stop half already exists (E2, E3). The blog says pair-programming users may want the opposite. Adopt only if long runs stop early. If adopted, do E22 and E24 too. |
| E10 | Output style | Sentences, Words, "Do not write" | KEEP | S4 | Style preference. Verbosity reports on Opus 5.5 are split, 4 against 3. |
| E11 | Output style | "Lead with the outcome." | EDIT (optional) | blog | Add: "If you need something from me, say it first." Blog: "look first for anything Claude is waiting on you for". |
| E12 | Output style | "Match the length of a written document…"; reference codes | KEEP | baseline | Opus 5 snippet stands. No forced analysis block, so no R2 or S1 risk. |
| E13 | `rules/instruction-files.md:25-29` | Judgment over MUST/NEVER | KEEP | baseline | Still valid. |
| E14 | `rules/instruction-files.md` (missing) | One sentence: no "think carefully", no "show your reasoning in the reply", name specific anti-patterns instead of "avoid generic" | EDIT | R1, R2, R4 | This file loads when a SKILL.md or CLAUDE.md is edited, so new instructions avoid the patterns. |
| E15 | `settings.json` · `modelSettings` | `"claude-opus-5": {"effortLevel": "medium"}` | EDIT | C1, C3 | Inert on Opus 5.5. Entries match by canonical name (`claude-opus-5-5`) and its aliases only. The effect is the same today, because `medium` is the Opus 5.5 default. Add a `claude-opus-5-5` entry to state the intent; Anthropic says "set it explicitly". |
| E16 | `settings.json` · `env` | `MAX_CONCURRENT_SUBAGENTS=3`, `MAX_SUBAGENT_SPAWN_DEPTH=2` | DECIDE | D1 | A backstop from the Opus 5 cap. The blog now says to fan out large audits. The cap of 3 blocked a fourth research agent today. Keep it, or raise the concurrency. |
| E17 | `settings.json` · `permissions.deny` | Secret reads | KEEP | — | A deterministic layer. |
| E18 | `settings.json` | `attribution`, `outputStyle`, `statusLine`, plugins | KEEP | — | — |
| E19 | `settings.json` | No `alwaysThinkingEnabled`, `MAX_THINKING_TOKENS` or top-level `effortLevel` | KEEP | C3, C4 | Nothing inert to remove. |
| E20 | Hooks | `guard-secrets.sh`, `guard-secrets-read.sh` | KEEP | system card | §6.3.1: a snapshot misdescribed `history -c` as a "no-op check". Guards should stay deterministic. |
| E21 | Hooks | `warden-handoff hook`; context monitor | KEEP | A1 | The monitor's "ask how they want to proceed" message is a stop you chose. |
| E22 | `permissions` (missing, G2) | `Bash(gh pr merge*)`, `Bash(git push -f*)` denies | ADD if E9 | blog | "A rule to keep going means fewer stops… Keep permission prompts on for destructive commands too." |
| E23 | Hooks (unwired, G1) | `guard-default-branch.sh` | ADD if E9 | blog | Same reason. At present, "never edit on the default branch" is prose only. |
| E24 | Skills | crit, crit-cli, design-taste-frontend, eli5, handoff, model-update, review-animations, source-authority | KEEP | — | No R1–R5 patterns and no stale model IDs. design-taste-frontend already names specific patterns (A8). The emphasis in crit is a real blocking gate. |
| E25 | Skill · emil-design-eng | 679 lines; lines 62–679 are lookup tables | MOVE | structure | Move to `references/`, as review-animations does. Not model-driven. |
| E26 | Skill · emil-design-eng | Duplicates `review-animations/STANDARDS.md` (easing, duration, spring, a11y) | EDIT | CLAUDE.md Reuse | Two copies will drift. Keep one reference and point to it from both skills. |
| E27 | superpowers · `hooks/session-start:27` + `using-superpowers/SKILL.md:10-16` | `<EXTREMELY_IMPORTANT>`, "even a 1% chance… you ABSOLUTELY MUST", "YOU DO NOT HAVE A CHOICE", "not negotiable" | EDIT | baseline | The Opus 5 overtriggering pattern, injected every session (~850 tokens). Observed today: `model-update` was invoked on your first request and you had to stop it. Keep the rule and state it plainly. |
| E28 | superpowers · `using-superpowers/SKILL.md:34-52` | 13-row "Red Flags" rebuttal table | EDIT | baseline | Repeats E27. Trim it together with E27. |
| E29 | superpowers · `writing-skills/persuasion-principles.md` | Teaches "YOU MUST", "No exceptions" as persuasion | EDIT | baseline | The source of the pattern. Every new skill written with it copies the pattern. |
| E30 | superpowers · verification-before-completion, systematic-debugging, test-driven-development | "Iron Law" ALL-CAPS headers | EDIT (tone only) | baseline | Keep the rules; they are evidence gates and process. Remove the shouting. |
| E31 | superpowers · brainstorming HARD-GATE, executing-plans stops, finishing-a-development-branch force gates | Approval gates | KEEP | A1, D2 | Named stops that you set up on purpose. They do not collide with A1. |
| E32 | superpowers · writing-plans, subagent-driven-development, code-reviewer | Relative model tiers; severity categories | KEEP | C#, baseline | No literal model IDs. Review reports everything, then categorizes. |
| E33 | diagram-design, pyright-lsp | Description only / no prompt | KEEP | — | ~186 tokens and 0 tokens. Third-party. |
| E34 | `docs/decisions/ARCHITECTURE.md:75`, `RESEARCH.md` §2 | Opus 5 effort and behavior notes | EDIT (record) | C1, C3 | Add an Opus 5.5 note: default `medium`, the `modelSettings` key. On-demand docs, low priority. |
| E35 | `README.md:44` | Status line example shows "Opus 5" | EDIT (cosmetic) | — | — |

## Priority

1. **E27–E29** — the only finding with observed harm in this session; it costs tokens every session.
2. **E15** — a one-line config fix; the effect is invisible today but breaks on any non-default choice.
3. **E9 + E22 + E23** — one decision; adopt all three or none.
4. **E14, E11** — small wording additions.
5. **E25, E26, E34, E35** — structure and records; not model-driven.

## Out of scope, noticed

`settings.json` has uncommitted changes (key reorder and regenerated Orca hook commands), and
`settings.json.bak` is untracked. Neither is related to Opus 5.5.

## Decisions and application (2026-09-23)

The user approved every row. Decisions on the DECIDE rows:

- **E9** adopted: `CLAUDE.md` gains a "Keep going" section.
- **E16** set to 20 concurrent subagents and depth 3, for an orchestrator over two Opus sessions,
  each with subagents. Both values equal the Claude Code defaults; they are set explicitly to
  record the choice.
- **E22, E23** adopted with E9. The branch guard was fixed first: it judged the session's cwd, so
  it blocked edits outside any repo and in branch worktrees while the session sat on `main`.

Branch `chore/opus-5-5-alignment` carries the Warden rows. The superpowers rows (E27–E30) go to
the fork `~/dev/superpowers2`; its `CLAUDE.md` requires eval evidence before and after a skill
behavior change, so they are held for that decision.
