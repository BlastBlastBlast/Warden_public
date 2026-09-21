# Where each instruction belongs — September 2026

`RESEARCH.md` covers what to say. This file covers where to put it.

## The mechanisms, ranked by how reliably they fire

| Mechanism | Fires because | Context cost | Reliability |
|---|---|---|---|
| **Settings** (`settings.json`) | Claude Code reads config | Zero | Absolute. Not a prompt. |
| **Permissions** (`permissions.deny`) | The client checks before the call | Zero | Absolute |
| **Hooks** | A lifecycle event occurs | Zero unless output returns | Absolute. The trigger is guaranteed. |
| **Output style** | Injected into the system prompt, every turn | Every request, never compacted | High. System prompt beats user message. |
| **CLAUDE.md** | Delivered as a user message after the system prompt | Every request | Medium. Degrades as the file grows. |
| **Rules, path-scoped** | Claude reads a matching file | Only when matched | Medium, and free when irrelevant |
| **Skill** | Claude matches your words to its `description` | Description only, until used | Medium. Body loads in full when it fires. |
| **Subagent** | Claude delegates | Isolated | Medium |

The rule Anthropic states plainly: *"An instruction like 'never edit .env' in CLAUDE.md or a skill is
a request, not a guarantee. A PreToolUse hook that blocks the edit is enforcement."*

So: **anything phrased as "always" or "never" is in the wrong place if it is in CLAUDE.md.**

## What we had, and where each piece moved

| Instruction (v1) | Was | Now | Why it moved |
|---|---|---|---|
| No AI attribution in commits and PRs | CLAUDE.md prose | `settings.json` → `attribution` | It is configuration, not judgment. Zero context, cannot be forgotten. `includeCoAuthoredBy` is deprecated; `attribution` replaces it. |
| Never edit on the default branch | CLAUDE.md prose | `hooks/guard-default-branch.sh` on `PreToolUse` | A hard "never". The hook denies the edit and tells Claude to branch. Tested: blocks on `main`, allows on a branch, no-ops outside a repo. |
| Do not merge pull requests | CLAUDE.md prose | `permissions.deny: ["Bash(gh pr merge:*)"]` + CLAUDE.md line | Deny makes it impossible. The CLAUDE.md line still tells Claude to hand the command over. |
| Writing style, 48 lines of STE rules | `rules/writing-style.md` | `output-styles/plain-technical.md` | Style is "how Claude responds every turn" — the documented job of an output style. It lands in the system prompt instead of a user message, and it is never compacted away. `keep-coding-instructions: true` keeps the engineering defaults. |
| Start the spec workflow on build/create/make | CLAUDE.md prose | `skills/new-work/SKILL.md` | A skill `description` is the documented trigger mechanism. It carries the size test in its body, so the boundary loads only when the question is live. |
| Skill authoring guide | `rules/skill-authoring.md` | unchanged | Already path-scoped to `**/SKILL.md`. Free when you are not writing a skill. |
| Research tiers | `rules/research.md` | unchanged, trimmed | Cannot be path-scoped and must shape every answer. An always-on rule is correct. |
| Command handoff format | CLAUDE.md | unchanged | Pure communication policy, always relevant, needs judgment. CLAUDE.md is right. |
| Reuse before you create | CLAUDE.md | unchanged | Judgment, always-on. Correct where it is. |
| Scope discipline (surgical changes, no speculative code) | CLAUDE.md, 5 bullets | **deleted** | Claude Code's own system prompt already carries scope control on Opus 5. Repeating it is the "repeat yourself" anti-pattern and it crowded out the rules that are ours. |
| Twice is a pattern → write it into the repo's CLAUDE.md | CLAUDE.md | **deleted** | Auto memory does this now, as a `feedback` memory, without being told. |

Result: **93 lines → 51 lines**, and the two rules that must never be missed are no longer prose.

## The tree

```
~/.claude/
├── settings.json                        attribution, permissions, hooks, subagent caps
├── CLAUDE.md                            ← CLAUDE.proposed.md   (51 lines)
├── hooks/
│   └── guard-default-branch.sh          PreToolUse: Edit|Write|NotebookEdit
├── output-styles/
│   └── plain-technical.md               STE discipline, keeps coding instructions
├── rules/
│   ├── research.md                      always on
│   └── skill-authoring.md               paths: **/SKILL.md
└── skills/
    └── new-work/SKILL.md                spec workflow vs direct edit
```

## Two things I deliberately did not do

**No `permissions.deny` on force push.** The obvious pattern `Bash(git push --force:*)` also matches
`git push --force-with-lease`, which is the form we want allowed. Permission patterns match on
prefix, so the safe rule would block the safe command. It stays a CLAUDE.md line. Verify the prefix
behaviour with `/permissions` before adding any `--force` rule.

**No Stop hook gating on tests.** Anthropic's strongest verification lever is a `Stop` hook that
blocks the turn until your check passes, or a `/goal` condition. Both need a real test command, so
they belong in a project's `.claude/settings.json`, not in the global setup. Worth adding per repo.

## Still worth considering

| Add | Trigger for adding it | Where |
|---|---|---|
| Code intelligence plugin | Claude greps to find where a symbol is defined | `/plugin`, per language |
| Status line showing context use | You want to see the window filling | `settings.json` → `statusLine` |
| `effortLevel` sweep | You carried an Opus 4.8 default over | Opus 5 docs say re-run the sweep; use `low`/`medium` liberally |
| `/doctor` | Any CLAUDE.md you have not pruned lately | Proposes trims for checked-in files |
| Project `.claude/settings.json` | A repo with a real test command | Stop hook or `/goal` |

## Install

```
cp -r rules skills output-styles hooks ~/.claude/
cp CLAUDE.proposed.md ~/.claude/CLAUDE.md
chmod +x ~/.claude/hooks/guard-default-branch.sh
```

Then merge `settings.json` into `~/.claude/settings.json` by hand. Do not overwrite that file.

## Sources

- [Extend Claude Code — match features to your goal](https://code.claude.com/docs/en/features-overview)
- [Steering Claude Code: when to use CLAUDE.md, skills, hooks, rules, subagents](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more)
- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [Settings reference](https://code.claude.com/docs/en/settings-reference)
- [Output styles](https://code.claude.com/docs/en/output-styles)
- [Subagents](https://code.claude.com/docs/en/sub-agents)
