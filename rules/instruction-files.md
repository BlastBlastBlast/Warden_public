---
paths:
  - "**/CLAUDE.md"
  - "**/AGENTS.md"
  - "**/SKILL.md"
  - "**/.claude/rules/**"
  - "**/.claude/settings*.json"
---

# Editing instruction files (CLAUDE.md, AGENTS.md, skills, rules)

Place guidance in the cheapest tier that still fires:

| Guidance shape | Tier |
|---|---|
| Universal, every task | CLAUDE.md — keep under 200 lines; per line ask "would removing this cause a mistake?" |
| "Every time X, do Y" | A hook (deterministic), not prose |
| "Must never happen" | `permissions.deny` or a PreToolUse guard, not prose |
| A fact that holds for certain paths | A `.claude/rules/*.md` with `paths:` frontmatter (its only supported field) |
| A procedure tied to certain paths | A skill with `paths:` frontmatter — stays out of the skill listing entirely until a matching file is touched |
| Only shapes a file being created from nothing | A `PreToolUse` hook on `Write\|Edit` — no `paths:` asset fires before a file's first write |
| Conditional on task type, no path predicts it | A skill — description states when to fire AND when not to |
| Lookup material (tables, skeletons, catalogs) | `references/*.md` inside the skill, loaded on demand and exempt from the compaction cap |

Writing style: judgment criteria over MUST/NEVER mandates — current models follow rigid rules
too literally and emphasis inflation causes overtriggering. State the criterion and the reason
("a wrapping CTA reads as broken"), not an ALL-CAPS ban. Skill descriptions are always-loaded:
keep them trigger-sharp, third-person, with negative scope, and never summarize the skill's
workflow in them.

Three instruction shapes fail on Opus 5.5 (`~/.claude/docs/references/opus5.5-claude-md-reference.md`).
"Think carefully" lines are dead weight: the model always thinks, and effort sets how much. "Show
your reasoning in the reply" can be refused as `reasoning_extraction`; ask for "why, in three
sentences" instead. "Avoid a generic look" swaps one default for another; name the patterns to
leave out.

## Authoring a skill

Personal: `~/.claude/skills/<name>/SKILL.md`. Project: `.claude/skills/<name>/SKILL.md`. Managed
beats personal beats project when names clash; plugin skills are namespaced as `/plugin:skill`.

Frontmatter worth knowing, beyond `name` and `description`:

| Field | Use it for |
|---|---|
| `disable-model-invocation: true` | Side-effecting workflows the author starts with `/name`. Zero context until invoked. |
| `user-invocable: false` | Background knowledge Claude applies, never a slash command |
| `allowed-tools` | Pre-approve the exact calls the skill needs, e.g. `Bash(git log:*)`. A path named here that does not exist still gets approved, then fails. |
| `paths` | Keep the skill out of the listing until a matching file is touched |
| `context: fork` | Run in a subagent when the skill reads a lot and returns a summary |
| `arguments` | Named placeholders, e.g. `arguments: [tag]` used as `$tag` |

Body: keep it short, because it stays in context for the rest of the turn. One action per numbered
step. Inject live state with a `!` command line rather than telling Claude to go fetch it. Put
lookup material in `references/*.md` beside the skill.

After creating one, name it and its trigger phrase in one line.

## Authoring a hook

**Fire on the event, not on every attempt.** Match the case that can actually cause the harm and stay
silent on the rest. A guard that asks on every call it matches, including calls that cannot do the
damage, buries its own signal: a reader asked on every edit approves without reading. Two instances
this month — a test guard that asked on an edit which only appended assertions, and a Stop hook that
reported the same drift on every turn.

**A Stop hook that reports reads `stop_hook_active` from stdin and exits 0 when it is true.** Both
`additionalContext` and `decision: "block"` feed the message back as a new turn, which ends in another
stop, which runs the hook again; the same loop protections cover both and Claude Code overrides the
hook after eight consecutive continuations (`code.claude.com/docs/en/hooks`). Answering such a hook
never clears it. Only changing the state it reads does.

**A block explains itself.** stderr on exit 2 is what the model sees, so name the condition and the
route past it — the gate is worth nothing if the reader cannot tell what would satisfy it
(`docs/ai-native-sdlc/10-deploy-hooks-as-gates.md`).

The full classification procedure (the five ordered questions, hook/rule authoring contracts,
and the current tier inventory) lives in `~/.claude/docs/references/enforcement-tiers.md` — read it
before converting prose to a hook or rule, or adding a new one.
