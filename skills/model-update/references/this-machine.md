# This machine's setup: layout, shipping flow, gotchas

Load when executing Phase 4 (apply/ship) on this machine. Rewritten 2026-09-20 for Warden.

## Where the setup lives

`~/dev/Warden` is the whole user-scope configuration and the source of truth for how Claude
operates on this machine. Paths inside `~/.claude` are symlinks into it, so **every edit is live
the moment it is saved**. There is no install step and no copy to keep in sync.

The methodology — brainstorm, spec, plan, execute, review, reconcile, finish — is **not** in
Warden. It comes from the `superpowers` plugin installed from the local fork at
`~/dev/superpowers2` (marketplace `superpowers-dev`). Warden holds the instruction surfaces:
`CLAUDE.md`, `settings.json`, `hooks/`, `output-styles/`, `rules/`, and the skills the plugin
does not cover.

Two layers, two places to edit:

| Change | Edit |
|---|---|
| A rule, a hook, a guard, the output style, a Warden-only skill | `~/dev/Warden` |
| A chain stage, TDD, debugging, skill-authoring method | `~/dev/superpowers2`, then reinstall the plugin |

## Shipping flow

1. Branch with a `feature/`, `fix/`, `refactor/` or `chore/` prefix.
2. Conventional commits grouped by surface (hook + its test / settings / skills / docs).
3. Validate `settings.json` parses after every edit. A broken settings file is a broken session
   on the next start, immediately, because of the symlink.
4. Re-run the secret-guard checks after touching either guard. They are the only two hooks wired,
   so nothing else catches a regression in them.

## Gotchas

- **Symlink liveness.** A branch switch in `~/dev/Warden` changes the running configuration
  underneath the session doing the switching. Use a worktree for feature work.
- **Orca's hooks live in `settings.json` too.** They register on nine events and their command is
  a base64 PowerShell payload inside a shell `case`. Preserve those entries verbatim through any
  settings edit; do not reformat or regenerate them.
- **`cd` in a compound Bash command may silently not apply.** Use `git -C <path>` and absolute
  paths; check `pwd` before repo surgery.
- **Plugin skills are namespaced.** A superpowers skill is `/superpowers:<name>`. A Warden skill
  is `/<name>`. When both cover a topic, the descriptions compete and triggering gets less
  reliable — that is the signal to delete one, not to reword both.
- **No declared harness version floor.** Nothing records which features the config depends on.
  When a model update adopts version-gated config, note the version it needs in the change
  record — older harnesses ignore unknown config silently. Map features to versions via
  `code.claude.com/docs/en/changelog`.
