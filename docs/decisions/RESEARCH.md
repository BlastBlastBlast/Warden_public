# Research notes — what a good Claude setup looks like in September 2026

Not deployed. This file records where the draft came from so we can re-check it later.

## 1. The big shift: Claude 5 needs less scaffolding, not more

Anthropic removed **over 80% of Claude Code's own system prompt** for Claude 5 generation models
with no measurable loss on coding evals. The stated reason: the model now handles nuance that used
to need rigid rules.

The five rewrites that matter for a `CLAUDE.md`:

| Then (Claude 4.x era) | Now (Claude 5 era) |
|---|---|
| Give Claude rules | Give Claude judgment + one concrete standard to match |
| Give Claude examples of tool use | Design the interface so the right use is obvious |
| Put it all upfront | Progressive disclosure — skills and path-scoped rules |
| Repeat yourself | Say it once, in the one place that owns it |
| Hand-maintained memory in CLAUDE.md | Auto memory writes itself; CLAUDE.md holds your rules |

Anthropic's own guidance on what a `CLAUDE.md` is for: **"Keep it lightweight; focus on gotchas and
unique repo details."** Everything else belongs in a skill or a path-scoped rule.

## 2. Opus 5 specifics — things to REMOVE from a pre-Opus-5 CLAUDE.md

Anthropic's Opus 5 prompting guide names four instructions that now actively hurt:

- **Verification instructions.** "Include a final verification step", "use a subagent to verify".
  Opus 5 verifies its own work unprompted. These cause over-verification and waste tokens.
- **Re-check instructions.** "Double-check your answer", "re-verify before responding". Same problem.
- **Inherited effort settings.** Re-run an effort sweep instead of carrying over Opus 4.8 defaults.
- **"Be conservative / only report high-severity issues"** in review prompts. Opus 5 follows this
  literally and reports less. Ask for everything, filter in a second pass.

And four constraints that are now worth **adding**, because Opus 5 changed behaviour:

- **Length.** Default responses and written files run longer than on Opus 4.8.
- **Scope.** Opus 5 expands scope and adds unrequested steps if not held to the ask.
- **Delegation.** Opus 5 spawns subagents more readily. Cap it.
- **Correction narration.** Opus 5 announces its own corrections more. Limit to corrections that
  change the user's code, conclusions or decisions.

**Important for us:** Claude Code's `claude_code` system prompt preset already carries scope,
correction-narration and delegation instructions on Opus 5. Repeating them in `CLAUDE.md` is the
"repeat yourself" anti-pattern. The draft therefore leaves them out and covers only what is ours.

## 3. Verdict on the Karpathy-style CLAUDE.md

Source: `multica-ai/andrej-karpathy-skills/CLAUDE.md`. Four sections. Two hold up fully, one
half, one is now counterproductive.

| Section | Verdict | Why |
|---|---|---|
| **1. Think Before Coding** — "if uncertain, ask", "if unclear, stop" | **Soften** | Opus 5 guidance is the opposite: make routine judgment calls yourself, check in only when different readings lead to materially different work. A stop-and-ask reflex now costs more turns than it saves. Keep "surface tradeoffs, state assumptions"; drop "stop and ask". |
| **2. Simplicity First** — minimum code, nothing speculative | **Holds** | Maps directly onto the Opus 5 scope-expansion tendency. Keep. |
| **3. Surgical Changes** — touch only what you must, clean up only your own orphans | **Holds, strongest section** | The single most useful rule in the file, and the one Opus 5 still needs. Kept nearly verbatim. |
| **4. Goal-Driven Execution** — define success criteria, loop until verified | **Half** | The good half is "give the work a check that returns pass/fail" — still Anthropic's #1 best practice. The bad half is instructing a verification loop and a written plan-with-verify-steps for every task; that is exactly the over-verification Opus 5 docs say to delete. Reframed as: the check is the deliverable, not a ritual. |

What the file is missing for 2026: response/document length calibration, delegation limits, anything
about skills, research sourcing, or handing commands back to the human.

## 4. Structure decisions for our set

- **`CLAUDE.md` under ~120 lines.** Anthropic targets under 200; adherence drops as it grows.
  "If Claude keeps doing something you don't want despite a rule against it, the file is probably
  too long and the rule is getting lost."
- **`rules/` does not save context unless path-scoped.** Unscoped `~/.claude/rules/*.md` load at
  launch with the same priority as `CLAUDE.md`. We use them for organisation, and we path-scope the
  one rule that can be path-scoped (`skill-authoring.md` → `**/SKILL.md`).
- **No duplication between the two.** `CLAUDE.md` points; the rule defines. Contradictions between
  memory files get resolved arbitrarily by the model.
- **Emphasis is a scarce resource.** "If you emphasize many lines, none of them stands out." One
  `IMPORTANT` at most, and only after we see a rule being missed.

## 5. Open item to verify before we swap the file in

`/superpowers` — the draft uses the trigger name as given. Confirm the exact command the installed
plugin exposes (`/plugin` → superpowers, or `ls ~/.claude/plugins`) and correct the name in
`CLAUDE.md` if it differs. The brainstorm → plan → subagent-driven-execute workflow is right; only
the entry-point string is unconfirmed.

## Sources

- [The new rules of context engineering for Claude 5 generation models](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models)
- [Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5)
- [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices)
- [How Claude remembers your project (CLAUDE.md and rules)](https://code.claude.com/docs/en/memory)
- [Claude Code skills](https://code.claude.com/docs/en/skills)
- [multica-ai/andrej-karpathy-skills CLAUDE.md](https://github.com/multica-ai/andrej-karpathy-skills/blob/main/CLAUDE.md)
- [ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/about_STE.html)
