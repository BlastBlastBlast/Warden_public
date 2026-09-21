# Installing Warden, with Claude

Claude: follow this file exactly. Do not improvise the steps.

## Step 1. Read the situation

Run these and read the output.

```bash
uname -s; uname -m
ls -la "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" 2>/dev/null | head -40
./install.sh --dry-run
```

## Step 2. Tell the person what will change, then stop

Say all of this, in your own words, before you write anything:

1. The installer archives their whole Claude configuration directory to
   `$HOME/.warden-backups/claude-<timestamp>.tar.gz`. Name the exact directory.
2. It links nine paths inside `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` to files in this repository:
   `CLAUDE.md`, `settings.json`, `hooks`, `output-styles`, `rules`, `skills`, `bin`,
   `docs/references`, `docs/decisions`. It also links `$HOME/.local/bin/warden-handoff`. List
   every path the dry run printed.
3. Anything already at one of those paths gets a new name,
   `<path>.warden-backup-<timestamp>`. The installer removes nothing.
4. It registers two plugin marketplaces through the `claude` CLI: the `superpowers` plugin
   vendored in this repository, and `cathrynlavery/diagram-design`. The `claude` CLI writes its
   own marketplace list for this.
5. It downloads two binaries, `claude-context-monitor` and `claude-statusline`, from the latest
   release of `stigsb/claude-context-monitor`, into `$HOME/bin`. It checks each one against the
   release's checksum file before it installs it.
6. It sets `core.hooksPath` to `.githooks` in this repository's own git configuration, so the
   pre-commit scrub hook runs. This changes only this clone's `.git/config`, not any global git
   setting. It skips this step when `core.hooksPath` already points somewhere else.
7. `./uninstall.sh` removes the links from step 2 and restores what they replaced. It does not
   remove the plugin marketplaces or the downloaded binaries, and it does not undo the
   `core.hooksPath` setting. It prints the commands to remove those by hand.
   `./uninstall.sh --from-archive <path>` restores the whole configuration directory from one
   archive instead.

Then ask: "Shall I run it?"

**Stop here. Write nothing until the person agrees.** A question is not consent. A "sounds
interesting" is not consent.

## Step 3. Run the installer

Do not reproduce the install steps by hand. One implementation carries the behavior.

```bash
./install.sh
```

## Step 4. Check the result, and report

Run these:

```bash
ls -la "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" | grep -- '->'
ls -la "$HOME/.local/bin/warden-handoff"
ls -la "$HOME/bin"
ls -la "$HOME/.warden-backups"
```

Report what you see. If a check fails, say which one and show the output.

**Do not correct a failed check.** Report it. The person decides what to do next. A correction
made without their knowledge is the failure this step exists to prevent.

## Step 5. Tell them what to do next

- Start a new Claude Code session, so the new `settings.json` loads.
- The status line should show two lines.
- `./uninstall.sh` is the way back for the links, and `$HOME/.warden-backups` holds the archive
  for a full restore with `--from-archive`.
