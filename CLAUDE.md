# Global instructions

These apply to every project. A repo's own `CLAUDE.md` or `AGENTS.md` beats this file.

## Git

- Never edit on the default branch. Branch before the first change: `feature/`, `fix/`,
  `refactor/`, `chore/` + a kebab-case slug.
- Conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`.
- Update a branch by rebasing onto the default branch. Never merge the default branch in.
- Push a rewritten branch with `--force-with-lease`, on your own branch only. Never plain `--force`.
- Do not merge pull requests. Stop at an open PR with green CI and hand me the command.

## When I have to run it, give me the command

Hand a command back only when the step needs me: an interactive login, a merge you were told to
hand over, something outside your sandbox, or a decision that is mine.

- Give the exact command on its own line. Do not describe it.
- Use real values. Write `gh pr merge 277 --merge -d`, never `gh pr merge <number>`.
- Put all the commands in one block, in run order, with the flags I want.
- Add one line on what it does and what to check. Then stop.
- In a Claude Code session, tell me I can run it in place with the `!` prefix.
- Do not ask permission for a command only I can run.

Reads, edits, tests, builds and lints are yours. Handing those back makes me the executor.

## Keep going

When a step does not need my input, keep going. Put status notes in the same message as your next
action. Stop and ask only when you cannot continue without me, or before anything destructive:
deleting data, force-pushing, or changing anything outside the repository you are working in.

## Which model does the coding

Sonnet 5.5 is the coding model. When a skill names a model tier, map it like this:

- Cheap tier and standard tier: `sonnet`. Do not send coding work to `haiku`.
- Most capable tier: `opus`. Keep it for architecture, design, and the final whole-branch review.

Name the model on every dispatch. A subagent with no model gets `CLAUDE_CODE_SUBAGENT_MODEL`.

## Reuse before you create

- Search before you write. Grep for the function name, the error string, the existing pattern.
- Extend the helper that already does the job. Do not add a second one beside it.
- Say what you reused. If you found nothing, say what you searched for.
- Two near-identical blocks are a pattern. At the third, extract it.

## Verification is part of done

- Test first for features and bug fixes. Skip only for one-line diffs.
- Give the work a check that returns pass or fail: a test, a build, a lint, a diff against a fixture.
- Run the check. Show the output. Never claim a pass you did not see.
- If a check fails and you stop, say so and show the failure.

## Research before you answer

Check current practice instead of recalling it for a new framework, a library API, a version, a
flag, a convention others will follow, and anything about Claude or Anthropic. Weigh sources by
authority and cite what you used.

## Turn a repeated job into a skill

The second time I ask for the same job, write a skill instead of explaining the process again.
Tell me its name and its trigger phrase. Details: `rules/instruction-files.md`.

## Twice is a pattern

When you make the same mistake a second time in a repo, write the fix into that repo's `CLAUDE.md`
under "Things Claude gets wrong" before you continue. Auto memory is machine-local; this is the
copy your team reads.
