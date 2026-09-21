# Spec: warden-public

Intent: `intent.md`. Date: 2026-09-21. Status: draft.

## Summary

This change creates a public repository that carries a complete Claude Code setup. A person
clones the repository on a new computer and runs one installer. The computer then has the same
instruction files, skills, hooks, plugins, status line and handoff tool as the machine the setup
came from.

## Terms

- **The repository** is `Warden_public`, at any path the person chooses.
- **The installer** is `install.sh` at the root of the repository.
- **The uninstaller** is `uninstall.sh` at the root of the repository.
- **The procedure** is `INSTALL.md`, the written install steps that Claude reads and carries out.
- **The surfaces** are `CLAUDE.md`, `settings.json`, `hooks/`, `output-styles/`, `rules/`,
  `skills/` and `docs/`.
- **The tools** are `bin/warden-handoff` and `bin/warden-statusline`.
- **The monitor** is the `stigsb/claude-context-monitor` release, which ships the two binaries
  `claude-context-monitor` and `claude-statusline` in one archive.

## Requirements

### Behavior

**REQ-1** The installer MUST link the surfaces into the Claude configuration directory.

- **REQ-1.1** The installer MUST resolve its own directory at run time. The installer MUST NOT
  read a path that the repository hard-codes.
- **REQ-1.2** The installer MUST write into `${CLAUDE_CONFIG_DIR:-$HOME/.claude}`. The installer
  MUST create that directory when the directory is absent.
- **REQ-1.3** The installer MUST create a symbolic link for each surface. An edit in the
  repository MUST take effect in the next Claude Code session.
- **REQ-1.4** The installer MUST link `bin/warden-handoff` into `$HOME/.local/bin`. The installer
  MUST create that directory when the directory is absent.
- **REQ-1.5** The installer MUST NOT link `docs/superpowers/`. That directory holds the change
  records for this repository and is not an instruction surface.
- **REQ-1.6** The installer MUST link `bin/` into the Claude configuration directory. The shipped
  `settings.json` names the tools by that path, so no setting holds the clone location.

*Proof: `tests/install_links.sh` runs the installer with `HOME` set to a temporary directory. The
test asserts that each expected link exists and points into the repository.*

**REQ-2** The installer MUST acquire the three external dependencies.

- **REQ-2.1** The installer MUST register the vendored superpowers marketplace. The installer MUST
  run `claude plugin marketplace add "$REPO/plugins/superpowers"` with the absolute path it
  resolved under REQ-1.1.
- **REQ-2.2** The installer MUST register the diagram-design marketplace from
  `cathrynlavery/diagram-design`. The installer MUST take the latest version and MUST NOT pin a
  version.
- **REQ-2.3** The installer MUST download the monitor archive that matches the operating system
  and the processor architecture of the computer. The installer MUST check the archive against
  the release `checksums.txt` before it unpacks the archive.
- **REQ-2.4** The installer MUST install both monitor binaries into `$HOME/bin`. The installer
  MUST create that directory when the directory is absent.
- **REQ-2.5** The installer MUST stop and MUST print the reason when no release asset matches the
  computer. The installer MUST NOT install a binary for another architecture.
- **REQ-2.6** The installer MUST report a missing prerequisite by name and MUST stop. The
  prerequisites are `git`, `jq`, `curl`, `tar`, `shasum` or `sha256sum`, and the `claude`
  executable.

*Proof: `tests/install_deps.sh` puts a stub `claude` and a stub `curl` on `PATH`, runs the
installer, and asserts the commands the installer called and the files it wrote. A second case
sets an unsupported architecture and asserts a non-zero exit and the printed reason.*

**REQ-3** The installer MUST be safe to run again.

- **REQ-3.1** The installer MUST move an existing file or directory aside before it replaces that
  file or directory. The installer MUST name the copy `<name>.warden-backup-<UTC timestamp>`.
- **REQ-3.2** The installer MUST leave an existing link alone when that link already points at the
  correct target.
- **REQ-3.3** The installer MUST NOT create a second backup for a link it already owns.
- **REQ-3.4** The installer MUST print one line per action, and MUST print a closing summary that
  counts the links it made, the links it kept, and the backups it took.
- **REQ-3.5** The installer MUST support `--dry-run`. With that flag the installer MUST print
  every action and MUST write nothing.

*Proof: `tests/install_idempotent.sh` runs the installer twice against the same temporary `HOME`.
The test asserts that the second run takes no backup, and that the summary counts zero new links.*

**REQ-4** The uninstaller MUST return the Claude configuration directory to its earlier state.

- **REQ-4.1** The uninstaller MUST remove only the links that point into the repository.
- **REQ-4.2** The uninstaller MUST restore the newest matching backup for each link it removes.
- **REQ-4.3** The uninstaller MUST NOT remove a file that the installer did not create.
- **REQ-4.4** The uninstaller MUST NOT remove the plugins or the monitor binaries. The
  uninstaller MUST print the commands that remove those, so the person decides.

*Proof: `tests/uninstall_restores.sh` seeds a temporary `HOME` with a real `settings.json`, runs
the installer, runs the uninstaller, and asserts that the original file returns byte for byte.*

**REQ-5** The procedure MUST let Claude perform the install with the person's consent.

- **REQ-5.1** The procedure MUST state every change to the computer before the first change. The
  statement MUST name each path the install writes to.
- **REQ-5.2** The procedure MUST instruct Claude to stop and to ask for consent after that
  statement. Claude MUST NOT write anything before the person agrees.
- **REQ-5.3** The procedure MUST instruct Claude to run the installer, and MUST NOT ask Claude to
  reproduce the install steps by hand. One implementation carries the behavior.
- **REQ-5.4** The procedure MUST tell Claude what to check after the install, and MUST tell Claude
  to report a failed check rather than to correct it.

*Proof: `INSTALL.md` is prose, so the proof is a review against REQ-5.1 to REQ-5.4 and one
recorded run on a second computer.*

### Data

**REQ-6** The repository MUST carry no content that is specific to one machine or one
organization.

- **REQ-6.1** The repository MUST NOT contain an absolute path that names a user account.
- **REQ-6.2** The repository MUST NOT contain the Orca agent hook blocks.
- **REQ-6.3** The repository MUST NOT contain the `sunstone-plugins` marketplace or any plugin
  from it.
- **REQ-6.4** The repository MUST NOT contain `RESTORE-shepherd.txt`.
- **REQ-6.5** The repository MUST NOT contain `skills/synced/`.
- **REQ-6.6** The repository MUST NOT contain a compiled binary.

*Proof: `tests/no_machine_content.sh` greps the tracked files for `/Users/`, `/home/`, `.orca`,
`sunstone`, and for any file that `file` reports as an executable. The test fails on a match.*

**REQ-7** The repository MUST carry the superpowers plugin as a vendored copy under
`plugins/superpowers/`.

- **REQ-7.1** The vendored copy MUST keep the upstream `LICENSE` file without change.
- **REQ-7.2** The vendored copy MUST keep the author attribution in
  `.claude-plugin/plugin.json`.
- **REQ-7.3** The vendored copy MUST keep the plugin name `superpowers`. Every skill reference in
  this setup reads `superpowers:<skill>`, and a rename breaks each one.
- **REQ-7.4** The vendored copy MUST carry a `NOTICE.md` that names `obra/superpowers` as the
  origin, names `BlastBlastBlast/more_superpowers` as the upstream of this copy, and states that
  this setup modifies the copy.
- **REQ-7.5** The vendored copy MUST NOT contain a `.git` directory.

*Proof: `tests/vendored_license.sh` compares `plugins/superpowers/LICENSE` against the upstream
file, asserts the plugin name, and asserts that `NOTICE.md` names both repositories.*

### Interface

**REQ-8** The README MUST describe every part of the setup.

- **REQ-8.1** The README MUST hold a table of the surfaces. Each row MUST give the path, the
  link target, and what the surface holds.
- **REQ-8.2** The README MUST hold a table of the wired hooks. Each row MUST give the hook, the
  event, and what the hook blocks.
- **REQ-8.3** The README MUST hold a table of the skills that ship in `skills/`. Each row MUST
  give the skill name and one line on when the skill fires.
- **REQ-8.4** The README MUST hold a table of the external tools. The table MUST list
  `obra/superpowers`, `github/spec-kit`, `danyuchn/asd-ste100-skill`,
  `cathrynlavery/diagram-design`, `Graphify-Labs/graphify`, `stablyai/orca`, `manaflow-ai/cmux`,
  `stigsb/claude-context-monitor`, `firecrawl/pdf-inspector` and
  `anthropics/claude-plugins-community`. Each row MUST give a link, one line on what the tool
  does, and whether the installer installs the tool.
- **REQ-8.5** The README MUST state the platforms the installer supports, and MUST state that
  Windows is not supported.
- **REQ-8.6** The README MUST state the licence of the repository and the licence of the
  vendored plugin.

*Proof: `tests/readme_sections.sh` asserts that each required table heading exists, and that the
external tool table holds the ten named repositories.*

### Operations

**REQ-9** The repository MUST hold a test suite that runs without network access and without
changing the computer.

- **REQ-9.1** Each test MUST run against a temporary `HOME` directory.
- **REQ-9.2** Each test MUST use a stub for `claude` and for `curl`.
- **REQ-9.3** `tests/run.sh` MUST run every test and MUST exit non-zero when any test fails.
- **REQ-9.4** The test suite MUST run on macOS and on Linux.

*Proof: `tests/run.sh` prints a pass or fail line per test and a final count. A run on this
computer shows the output.*

## Non-goals

- **Windows support.** The hooks and the tools are bash scripts. A Windows port is a separate
  change.
- **A merged instruction file.** `CLAUDE.md`, `rules/`, `output-styles/` and `docs/references/`
  load on different triggers. Merging them loads every word into every session.
- **Repointing `~/dev/Warden` at the new repository.** The two repositories stay separate until a
  later decision.
- **Installing the seven tools that the installer only lists.** `spec-kit`, `asd-ste100-skill`,
  `graphify`, `orca`, `cmux`, `pdf-inspector` and `claude-plugins-community` appear in the README
  table with links. The installer does not touch them.
- **Publishing `more_superpowers`.** That is a separate action on a separate repository. This
  change only names it.
- **Keeping the vendored plugin up to date automatically.** A refresh is a manual copy and a
  commit.

## Constraints applied

**Rules and area guides**

- `/Users/trustherelwt/.claude/CLAUDE.md`, the global instruction file. It sets the branch rule,
  the conventional commit format, the reuse rule, and the rule that verification is part of done.
  REQ-9 exists because of that last rule.
- `/Users/trustherelwt/dev/Warden/rules/instruction-files.md`, which governs how an author writes an
  instruction surface. The README and the vendored skills follow it.
- `/Users/trustherelwt/dev/Warden/output-styles/plain-technical.md`, the writing discipline. This
  spec follows it.

**Policy skills**

The repository has no domain. It holds configuration, shell scripts and documentation. It
processes no personal data, no money and no authentication. There is no policy skill to apply,
and the absence is not a gap.

## Flagged concerns

**C1. A symlinked `settings.json` in a public repository can receive machine-specific writes.**

REQ-1.3 links `settings.json` from the repository into `~/.claude`, so an edit in the repository
is live. REQ-6.1 forbids an absolute user path in the repository. Claude Code writes to
`~/.claude/settings.json` by itself. The `/config` command, a permission the person always
allows, and some plugin operations all write there. Each of those writes lands in the public
repository. One of them can carry a machine path or a private marketplace.

The two rules cannot both hold without a guard. The options:

- **C1-a.** Keep the symbolic link and add a pre-commit hook that runs
  `tests/no_machine_content.sh`. A bad write still reaches the working tree, but never a commit.
  Cost: the person must install the git hook, and a blocked commit interrupts work.
- **C1-b.** Generate `~/.claude/settings.json` as a real file from a template in the repository.
  Cost: an edit in the repository is no longer live. The person must run the installer again.
- **C1-c.** Keep the symbolic link and accept the risk. Cost: a leak is possible, and the
  repository is public.

I recommend C1-a. It keeps the property the current setup has and it makes REQ-6 enforceable.
Lars owns this decision.

**C2. The intent says the installer targets macOS. The later instruction says "as general as
possible".**

The monitor ships Linux binaries. The hooks and the tools are bash and jq, which run on Linux.
REQ-9.4 therefore requires the tests to run on Linux as well. This widens the intent. The
alternative is to keep macOS only and to reject a Linux run.

I recommend the wider scope, because it costs one `uname` branch in the installer. Lars owns this
decision.

## Open questions carried from intent

- **Answered.** The marketplace path question. `~/.claude/plugins/known_marketplaces.json` is
  machine-local state that the `claude plugin marketplace add` command writes. It is not part of
  the repository. The installer therefore registers the vendored marketplace by absolute path at
  run time, under REQ-2.1, and the repository ships no path. The shipped `settings.json` keeps
  `enabledPlugins`, which names `superpowers@superpowers-dev` and needs no path. This resolution
  depends on the ruling for C1.
- **Answered.** The consent point for the Claude-driven install. REQ-5.1 and REQ-5.2 define it.
- **Answered.** The behavior when no release asset matches the computer. REQ-2.5 defines it.

## Design notes

The repository keeps the layout that `~/dev/Warden` already has, and adds four things:
`install.sh`, `uninstall.sh`, `INSTALL.md`, and `plugins/superpowers/`.

The two tools need no change. `bin/warden-statusline` already reads
`CONTEXT_STATUSLINE`, with `$HOME/bin/claude-statusline` as its default. `bin/warden-handoff`
already reads `WARDEN_HANDOFF_ROOT`, with `$HOME/.claude/handoffs` as its default. Both fall back
correctly when a binary is missing. The installer reuses those defaults rather than adding a
second configuration path.

The shipped `settings.json` differs from the current one in three ways. It drops every Orca hook
group. It drops the `extraKnownMarketplaces` entry that names an absolute path. It keeps the two
secret guards, the context-monitor `PostToolUse` hook, the `SessionStart` handoff hook, the status
line, the permission lists, and the subagent caps. The `statusLine` command and the `SessionStart`
command both change from `$HOME/dev/Warden/bin/...` to
`${CLAUDE_CONFIG_DIR:-$HOME/.claude}/bin/...`, and the installer links `bin/` into the Claude
configuration directory. That removes the last assumption about where the person cloned the
repository.
