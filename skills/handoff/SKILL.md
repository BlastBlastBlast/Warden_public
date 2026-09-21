---
name: handoff
description: Use when ending a session, handing off work for a fresh session, or the user says
  "hand off", "wrap up", "write a handoff", or asks to /clear and continue later. Writes a
  continuation-ready handoff doc outside the repo and hands back a paste-ready resume prompt.
  Not for mid-task checkpointing — commit and keep going.
allowed-tools: Read, Glob, Grep, Write, Bash(warden-handoff:*), Bash(git status:*), Bash(git log:*), Bash(pbcopy)
---

# Session handoff

A handoff is complete when a fresh session can resume from one paste. Write the doc, hand back the
prompt, then tell the user to `/clear`.

## Where handoffs live

Outside any working repo, under `~/.claude/handoffs`, so "never committed" is structural rather
than a rule to remember in each repo's `.gitignore`. `warden-handoff` owns the layout — never
hand-build these paths:

```
~/.claude/handoffs/<worktree-slug>/
  <YYYY-MM-DD-HHMM>-<topic>.md
  latest.md              -> the newest handoff; stable path, the manual fallback
  PENDING.<pane-key>     -> consumed by the SessionStart hook, so it fires once
```

The directory is per **worktree**, not per repo: parallel agents each work in their own worktree on
their own branch. The pending pointer is per **session**, so two agents sharing a worktree cannot
consume each other's handoff.

## Writing it

```bash
DIR=$(warden-handoff dir)
FILE="$DIR/$(date +%Y-%m-%d-%H%M)-<topic>.md"
```

Commit finished work first, so the doc can reference commits instead of uncommitted state.

Write to `$FILE`, ordered by what the next session reads first. **No continuation prompt inside the
file** — the file is what the prompt points at, so a copy of it at the top only goes stale.

1. **`# <Topic>`** as the first line. The hook reads this heading back to confirm it resumed the
   right handoff, so make it specific: "Statusline wired, limits line pending", not "Handoff".
2. **State** — what is finished, with evidence: test output, commit SHAs. What is in flight. What
   is untouched.
3. **Decisions and why** — anything a fresh session would otherwise re-litigate.
4. **Gotchas** — the non-obvious things that cost time this session.
5. **Next action** — the single concrete thing to do first.

Conclusions belong in the doc, not in chat scrollback. Write them down even when they were already
said in conversation.

## Then arm it and hand back

```bash
warden-handoff pointer "$FILE"
```

Print the continuation prompt in chat **and** copy it, because `/clear` wipes the transcript — a
prompt that exists only in scrollback is unrecoverable the moment it is needed:

```bash
printf '%s' "Resume the handoff at $FILE — read it and continue from its Next action." | pbcopy
```

Close by telling the user, in this order: the file path, that the prompt is on their clipboard, and
that after `/clear` the hook should offer the handoff by itself — `⌘V` if it does not.

## Why four layers

The hook is convenience, never load-bearing. The file is on disk before the `/clear`, so the
fallback ladder is: hook fires → say `go`; hook silent → `⌘V`; clipboard clobbered → say
`resume the handoff at ~/.claude/handoffs/<slug>/latest.md`. No rung loses work.

To satisfy yourself the hook works before trusting it — this prints what Claude Code would send and
changes nothing except consuming the pending pointer:

```bash
echo '{"source":"clear","cwd":"'"$PWD"'"}' | warden-handoff hook
```

Fires on `/clear` only. After quitting and relaunching, resume via `latest.md` by hand.
