# Intent: session token tracking

Author: Lars. Date: 2026-10-02. Status: approved.

## Problem
Lars runs several Claude sessions, both in sequence and in parallel. Some of them are an Opus
session that runs many subagents. The status line shows context and plan-limit percentages,
but not how many tokens the current session used, or on which model. Subagent tokens are not
in the status line data at all, so the cost of a workflow with many agents cannot be seen
while it runs.

## Proposed outcome
- The status line shows the tokens of the current session, subagents included, split by model.
  It shows nothing about other sessions, so it stays clean.
- One simple command shows totals across all sessions by day, week, month and session, split
  by model. Lars uses that view to evaluate how much a workflow costs.

## Affected users and systems
- Lars only.
- `bin/warden-statusline` in Warden.
- The transcripts in `~/.claude/projects/`, read only.

## Constraints
- The status line stays fast. It refreshes every 10 seconds, and several sessions run it at the same time.
- The transcripts are only read, never changed.
- The counts remove the duplicate records that Claude Code writes, so the numbers are not too high.
- The existing context line and plan-limit line keep working.
- Existing tools are reused where they already do the job. ccusage is the first candidate for the view across all sessions.

## Out of scope
- A web dashboard or a separate app that must keep running.
- Data from other machines, or data from claude.ai chat.
- Money cost as the main measure. Tokens come first.

## How we will know it worked
- After a session with subagents, the status line count for that session matches the ccusage
  session report within a few percent.
- Within a week, Lars uses the command to compare at least two workflows.

## Open questions
- Where does Claude Code write a subagent at spawn depth 2 or 3? No local data exists yet.
- Which numbers go in the status line segment: output only, or output plus cache write plus cache read?
- Is a lifetime total for each session enough, or does Lars also want "since the last /clear"?
- Does ccusage count subagents in exactly the same way as the status line segment? If not, which one is correct?
- What is the command called? Proposal: `warden-usage`.
