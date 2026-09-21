# Enforcement tiers: turning CLAUDE.md prose into hooks, rules, and skills

How to decide where a piece of guidance belongs, and how to author each tier. This is the
procedure behind the 2026-08 Opus 5 alignment; the `model-update` skill applies it on every
model release, and the `instruction-files` rule loads the short version whenever an
instruction file is edited.

## The classification procedure

For each line of CLAUDE.md (or any candidate guidance), ask in order:

1. **Is the violation observable in a tool call?** (a command string, a tool input field,
   a file write) → **hook**. Prose can stay as *generative* guidance — the prose tells
   Claude what to produce, the hook guarantees drift is caught. Examples here:
   conventional-commit prefix, bare force-push, AI-attribution footers, merge-main-into-
   feature, model-less generic subagent dispatch.
2. **Is it a "must never happen" expressible as a command/path pattern?** →
   **`permissions.deny`** (simpler than a hook when a glob suffices; a hook when the
   pattern needs logic a glob can't express, like the force-with-lease exception).
3. **Is it conditional on file paths, and does it have to be *present* at a moment the
   agent cannot predict?** → **`.claude/rules/*.md`** with `paths:` frontmatter. Loads in
   full when Claude reads a matching file. Glob syntax is documented at
   `code.claude.com/docs/en/memory` under "Path-specific rules" — read it there rather than
   inferring it from behaviour. Weigh the size: the whole body enters context on every
   matching read.
4. **Does it only have to be *reachable* when the agent knows it wants it?** → an
   **on-demand reference** under a router skill (`skills/<name>/references/*.md`).
   The cheapest tier: nothing loads until someone asks for that one file.
5. **Is it conditional on task type, with no path that predicts it?** → **skill** with a
   trigger-sharp description and negative scope.
6. **None of the above (pure judgment)?** → it stays prose in CLAUDE.md, and must pass
   "would removing this cause a mistake?"

**What NOT to convert:** judgment calls (reuse-before-create, test-where-risk-concentrates,
scope discipline). A hook that polices judgment produces false positives and teaches
workarounds; prose is the right tool there. More hooks is not better — every hook runs on
every matching event, and every false positive costs a retry. Each one must earn its place
with a concrete failure it prevents.

## Authoring hooks (PreToolUse guards)

Contract (docs: code.claude.com/docs/en/hooks): JSON payload on stdin (`tool_name`,
`tool_input`, …); **exit 2 blocks the call** (≥ 2.1.214), exit 0 allows; stderr becomes the
model-visible reason. House conventions:

- **Fail open** on unparseable input — a guard is defense in depth, not the only gate.
- **Only 0 and 2 mean anything.** Every other exit is a non-blocking error the harness reads as
  *allow*, so a guard that crashes stops guarding and says nothing. Give every extraction that can
  legitimately find nothing a branch returning empty, and never write a bare `var="$(pipeline)"` under
  `set -e` with `pipefail`. Measured 2026-09-14: `claude-guard-destructive` exited 1 on any
  `git commit` carrying no literal `-m`, aborting before its own attribution check, so every heredoc
  commit went unchecked for a month.
- **Assert exit codes in the test, not output.** The crash above printed nothing to stdout and every
  output-matching assertion passed while the guard was dead.
- **Segment-scope command matching**: a flag must appear in the same `|;&`-free segment as
  its command, or strings in unrelated commands false-positive (learned when the force-push
  guard blocked its own test suite).
- Expect **self-triggering**: a guard that matches patterns will match those patterns quoted
  in commit messages and heredocs. Write the block-reason to allow rephrasing, and keep
  pattern-shaped content in script files.
- **Test-first in `hooks/tests/run.sh`** — one case per block, one per legitimate near-miss (the
  force-with-lease, the CLAUDE.md mention, the amend without message, the `.env.example` read).
- Wire in `settings.json` under `hooks.PreToolUse` with the tool-name matcher. A hook under `hooks/`
  is reached through `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/`; one under `bin/` is reached through
  `$HOME/.local/bin/`, which is where the shell finds it too.

## Authoring hooks that report (Stop)

Contract (docs: code.claude.com/docs/en/hooks): Stop and SubagentStop receive `stop_hook_active`
on stdin alongside the common fields. It is `true` when the session is already continuing because
of a stop hook. `additionalContext` is the reporting channel — the transcript labels it `Stop hook
feedback` and shows no error notification — but it runs through the same loop protections as
`decision: "block"`: the harness feeds the message back as a turn, that turn ends in another stop,
and the hook runs again until the eight-continuation cap ends it.

- **Read stdin even when the payload is otherwise unused.** `hooks/config-drift.sh` never read it,
  so it never saw the field. Measured 2026-09-14: the hook repeated on every turn until the harness
  capped it, and replying to it changed nothing, because a report describes state the model cannot
  alter by answering. Only the state moves it.
- **Report once per stop, not once per attempt to stop.** `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` raises
  the cap for a hook that converges. A hook that reports does not converge, so narrow the trigger
  rather than raise the cap.
- **Every Stop hook here reports.** `config-drift.sh` and `plan-drift.sh` both advise and never
  block, so both carry the check.

## Compaction budget

Compaction re-attaches only the last **5,000 tokens per skill**, under a **25,000-token**
combined skill budget, so an oversized skill comes back truncated mid-document. Keep every
SKILL.md comfortably under that and put lookup material in `references/*.md`, which is read
on demand and not subject to the cap.

## Authoring rules

- One `.md` per concern; `paths:` (glob array) is the only supported frontmatter field.
  Without it the rule loads always — then it belongs in CLAUDE.md instead.
- User-level (`claude/rules/` → `~/.claude/rules/`) for cross-repo path patterns;
  repo-level (`.claude/rules/`) for this repo's own conventions.
- Keep each rule as lean as a CLAUDE.md section: judgment criteria, no MUST/NEVER
  scaffolding. Verify loading with `/context` (Memory files section).

## Current inventory (keep in sync)

| Guidance | Tier | Where |
|---|---|---|
| Protected paths a project declares | Hook (blocks) | `hooks/guard-protected-paths.sh` |
| Credentials in a written file | Hook (blocks) | `hooks/guard-secrets.sh` |
| Credentials read back over Bash | Hook (blocks) | `hooks/guard-secrets-read.sh` |
| Editing an existing test file | Hook (asks) | `hooks/guard-test-files.sh` |
| A chain stage written out of order | Hook (blocks) | `hooks/guard-stage-order.sh` |
| Spec language, after a document write | Hook (advises) | `hooks/ste-lint-spec.sh` |
| Diff departing from `plan.md` | Hook (advises, Stop) | `hooks/plan-drift.sh` |
| Secrets reads | Deny | `settings.json` permissions |
| Response shape, scope, verification | Prose (always on) | `rules/response-style.md` |
| Which model runs what | Prose (always on) | `rules/model-selection.md` |
| Spec/plan/decision-record language | Rule (path-scoped) | `rules/spec-language.md` |
| The artifact chain | Rule (path-scoped) | `rules/change-records.md` |
| Test craft and red-green-refactor | Rule (path-scoped) | `rules/tests.md` |
| Instruction-file tiering | Rule (path-scoped) | `rules/instruction-files.md` |
| Capturing what someone wants | Skill | `skills/capture-intent` |
| Writing requirements | Skill | `skills/author-spec` |
| Debugging | Skill | `skills/systematic-debugging` |
| Working through review feedback | Skill | `skills/receiving-review` |
| Design exploration | Skill | `skills/brainstorming` |
| Authoring instruction assets | Skill | `skills/writing-skills` |
| Controlled-language rewriting | Skill | `skills/asd-ste100` |
| Session handoff protocol | Skill | `skills/handoff` |
| Everything judgment-shaped | Prose | `CLAUDE.md` (under 65 lines) |

## The three ported guards

Ported from claude-setup and wired in `settings.json` on 2026-09-14. They live in `bin/`, not
`hooks/`, because the shell also calls them:

| Guidance | Tier | Where |
|---|---|---|
| Destructive shell commands (fetch-into-shell, bare force push, merge main in, AI attribution) | Hook (blocks) | `bin/claude-guard-destructive` |
| Generic subagent dispatch with no `model` set | Hook (blocks) | `bin/claude-guard-agent-dispatch` |
| Spec language at a document's *creation* | Hook (blocks) | `bin/claude-spec-language pre` |

`hooks/ste-lint-spec.sh` still runs after the write and advises. The two halves are deliberate: the
block covers the first write of a document that does not exist yet, which no rule can reach, and the
advisory pass covers prose quality, which is judgement.

## Gaps this inventory does not cover

- **Message extraction in `claude-guard-destructive`.** Item 1 of claude-setup's
  `docs/specs/2026-09-11-commit-stdin-attribution-hole-design.md` is fixed (the crash). Items 2 to 5
  are not: `git commit -m "$(cat <<'EOF' ...)"` still false-positives on the extracted `$(cat <<`, and
  a message file written by an earlier, separate tool call is never inspected. That spec has not been
  ported and is the only record of the remaining work.
