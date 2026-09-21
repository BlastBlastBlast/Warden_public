# Intent: warden-public

Author: Lars. Date: 2026-09-21. Status: approved.

## Problem

The Claude Code setup on this machine works, but it cannot move. `~/.claude` symlinks into
`~/dev/Warden`, which has no git remote. The development method lives in a second repo at
`~/dev/superpowers2`, which is private. The status line and the context monitor are two binaries
dropped in `~/bin`. Two plugins come from GitHub marketplaces. Setting up a new computer means
rebuilding all four parts by hand and remembering what was wired where.

## Proposed outcome

One public GitHub repo, `Warden_public`. A person clones it on a new machine, runs one installer,
and the machine has the same Claude Code setup: the instruction surfaces, the superpowers method,
diagram-design, the secret guards, the handoff, the two-line status line, and the context-monitor
warning.

The installer works two ways:

1. A shell script the person runs directly.
2. A written procedure Claude reads and carries out, step by step, with the person's consent.

Both paths reach the same end state. Neither assumes this machine, this user name, or this
directory layout.

The README lists every part of the setup and says what it does. It also carries a table of the
external tools this setup draws on, with a one-line description and a link each.

## Affected users and systems

- `~/.claude` on the target machine. The installer writes symlinks into it and backs up what it
  replaces.
- `~/.local/bin`. The installer links `warden-handoff` there.
- `~/bin`. The installer downloads `claude-statusline` and `claude-context-monitor` there.
- `~/dev/Warden` on this machine. Untouched. `Warden_public` is a separate repo.
- `BlastBlastBlast/superpowers2`. Published as the public repo `more_superpowers`, so the vendored
  copy has a named upstream.

## Constraints

- The repo is public. It carries no absolute path from this machine, no private marketplace, and no
  Orca hook block.
- The installer makes no assumption about where the repo is cloned, what the user name is, or
  whether `~/bin` and `~/.local/bin` already exist.
- No committed binaries. The installer downloads the context-monitor release that matches the
  machine's architecture.
- Superpowers is MIT, copyright 2025 Jesse Vincent. The vendored copy keeps the LICENSE, keeps the
  author attribution, and states that it is modified.
- The vendored plugin keeps the name `superpowers`. Every skill reference in the setup reads
  `superpowers:<skill>`, and a rename breaks all of them.
- The existing symlink model stays. An edit in the repo is live on the next session start.
- The installer never overwrites a file without backing it up first.
- The installer is idempotent. Running it again after `git pull` is safe.

## Out of scope

- The Sunstone plugins and the Orca agent hooks. Both are dropped from the shipped configuration.
  The README names Orca in the tool table.
- Windows. The installer targets macOS first and states its platform limits.
- Repointing `~/dev/Warden` at the new repo. That is a later decision.
- Merging the instruction surfaces into one file. `CLAUDE.md`, `rules/`, `output-styles/` and
  `docs/references/` keep their separate tiers, because Claude Code loads them on different
  triggers.
- `andrej-karpathy-skills`. Excluded from the tool table by request.

## How we will know it worked

A person clones `Warden_public` on a second Mac, runs the installer, starts Claude Code, and finds:
the status line shows two lines, `/handoff` is offered after `/clear`, a write carrying a private
key is blocked, and `superpowers:brainstorming` triggers on a creative request. One session, no
manual repair.

## Settled questions

- `Warden_public` lives at `~/dev/Warden_public` as a fresh repo. `~/dev/Warden` is untouched.
- The installer is idempotent and safe to re-run after `git pull`.
- `diagram-design` is fetched at latest, not pinned.
- `RESTORE-shepherd.txt` is dropped as machine-specific.
- The superpowers fork is published as the public standalone repo `more_superpowers`, not as a
  GitHub fork. MIT permits this. The README states the provenance.

## Open questions

- `extraKnownMarketplaces` names a marketplace by absolute directory path. A repo cloned to an
  arbitrary location cannot hardcode one. The spec must choose between generating `settings.json`
  from a template and linking the vendored plugin to a fixed path under `~/.claude`.
- The Claude-driven install path needs a defined consent point: what Claude states before it writes
  anything, and what the person agrees to.
- The context-monitor download needs a defined behaviour when no release matches the machine's
  architecture.
