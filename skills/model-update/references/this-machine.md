# The installed setup: layout, shipping flow, gotchas

Load when executing Phase 4 (apply/ship) on a machine that runs this setup. Rewritten
2026-09-21 for the installed layout.

## Where the setup lives

The Warden clone is the whole user-scope configuration and the source of truth for how Claude
operates on this machine. The clone lives wherever the person put it: `install.sh` resolves its
own directory at run time and nothing records a fixed path. Find it by following a link —
`ls -l "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md"` names the clone.

`install.sh` links nine paths inside the Claude configuration directory to files in the clone,
so **every edit to a linked surface is live the moment it is saved**. There is no copy to keep in
sync. A *new* top-level surface is the exception: it needs a name in `WARDEN_SURFACES` (or
`WARDEN_DOC_SURFACES`) in `lib/warden-common.sh` and another `install.sh` run before it is
linked.

The methodology — brainstorm, spec, plan, execute, review, reconcile, finish — is **not** in the
instruction surfaces. It ships as the `superpowers` plugin vendored at `plugins/superpowers/`
inside the same clone, which `install.sh` registers as the local marketplace `superpowers-dev`.
The rest of the clone holds the instruction surfaces: `CLAUDE.md`, `settings.json`, `hooks/`,
`output-styles/`, `rules/`, `docs/references/`, `docs/decisions/`, and the skills the plugin does
not cover.

Two layers, two ways an edit takes effect:

| Change | Edit | Takes effect |
|---|---|---|
| A rule, a hook, a guard, the output style, a Warden-only skill | the clone's linked surfaces | Immediately, through the link |
| A chain stage, TDD, debugging, skill-authoring method | `plugins/superpowers/` in the clone | After the plugin is updated through the `claude` CLI — it is not linked |

## Shipping flow

1. Branch with a `feature/`, `fix/`, `refactor/` or `chore/` prefix.
2. Conventional commits grouped by surface (hook + its test / settings / skills / docs).
3. Validate `settings.json` parses after every edit. A broken settings file is a broken session
   on the next start, immediately, because of the symlink.
4. Run `bash tests/run.sh`. It must end `0 failed`.
5. Re-run the secret-guard checks after touching either guard. They are the only two hooks that
   can block a tool call, so nothing else catches a regression in them.
6. The clone wires `.githooks/pre-commit`, which refuses a commit that would publish a machine
   path. Do not work around it; fix the file it names.

## Gotchas

- **Symlink liveness.** A branch switch in the clone changes the running configuration
  underneath the session doing the switching. Use a worktree for feature work.
- **`cd` in a compound Bash command may silently not apply.** Use `git -C <path>` and absolute
  paths; check `pwd` before repo surgery.
- **Plugin skills are namespaced.** A superpowers skill is `/superpowers:<name>`. A Warden skill
  is `/<name>`. When both cover a topic, the descriptions compete and triggering gets less
  reliable — that is the signal to delete one, not to reword both.
- **The configuration directory is not always `~/.claude`.** `CLAUDE_CONFIG_DIR` overrides it,
  and every script here reads it through that variable. Write it the same way.
- **No declared harness version floor.** Nothing records which features the config depends on.
  When a model update adopts version-gated config, note the version it needs in the change
  record — older harnesses ignore unknown config silently. Map features to versions via
  `code.claude.com/docs/en/changelog`.
