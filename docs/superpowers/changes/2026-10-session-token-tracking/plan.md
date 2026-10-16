# Session Token Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan wave by wave. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show the current session's tokens per model, subagents included, as a third status line,
and give one command that reports usage across all sessions by day, week, month and session.

**Architecture:** A new helper, `bin/warden-session-tokens`, reads one session's transcript and its
subagent transcripts, removes duplicate response lines, sums tokens per model and caches the result
per session. `bin/warden-statusline` prints the helper's one-line output as line 3. A thin wrapper,
`bin/warden-usage`, runs a pinned ccusage for the view across all sessions.

**Tech Stack:** bash, jq 1.7+, BSD `stat` (macOS) with a GNU fallback, ccusage 20.0.26 through `npx`.

**Spec:** `docs/superpowers/changes/2026-10-session-token-tracking/intent.md` (bounded change, no spec).

## Global Constraints

- Transcripts in `~/.claude/projects/` are read only. No script writes, moves or deletes them.
- A status line render with a warm cache runs no `jq` over transcripts.
- A failure in the token helper never removes line 1 or line 2 of the status line.
- Tests follow the repo convention: a plain bash script `*.test.sh` that prints `PASS`/`FAIL` per
  case and exits 0 only when every case passes. No bats.
- Every new script passes `shellcheck` with no warnings.
- ccusage version is pinned to exactly `20.0.26`.

## Facts measured during brainstorming

- Main transcript: `~/.claude/projects/<project>/<session-id>.jsonl`.
- Subagent transcripts: `~/.claude/projects/<project>/<session-id>/subagents/agent-<id>.jsonl`,
  each with a sibling `agent-<id>.meta.json`. All 298 local subagents have `spawnDepth: 1`.
- A usage line has `.type == "assistant"`, `.message.id`, `.message.model`, `.requestId` and
  `.message.usage` with `input_tokens`, `output_tokens`, `cache_creation_input_tokens` and
  `cache_read_input_tokens`.
- Claude Code writes several lines for one streamed response, all with the same `.message.id`. Only
  the **last** line carries the final `output_tokens`. Input and cache counts are equal on all lines.
- Lines with `.message.model == "<synthetic>"` carry zero usage and are not real API calls.
- Reference numbers for session `97dcc43a-6b31-4e12-b679-a1180c4cf249` (46 subagents), from
  ccusage 20.0.26 `session --json`, which this plan's helper also produced when keeping the last line:

  | model | input | output | cache write | cache read |
  |---|---|---|---|---|
  | `claude-sonnet-5` | 4680 | 752910 | 14026944 | 369673759 |
  | `claude-opus-5-5` | 2116 | 330500 | 6553189 | 222748511 |
  | `claude-haiku-4-5-20251001` | 66 | 696 | 72072 | 393300 |

- A full scan of that session (86 MB) takes about 0.5 s.

## Risks, worst first

1. **Wrong numbers that look right (Task 1).** If the helper keeps the first line of a streamed
   response, output tokens are too low by up to 5x. If it keys on `message.id + requestId`, a `/btw`
   sidechain replay counts the parent's cache reads twice. Cost: Lars evaluates workflows on false
   data. Task 1 carries the most risk and gets the most test cases; the acceptance check against
   ccusage runs after the last wave.
2. **A slow or broken status line (Tasks 1 and 3).** Several sessions render every 10 s. A cold scan
   of a large session takes 0.5 s; without the cache every render pays it. A crash in the helper must
   not blank the status line. Tests cover the cache hit and the missing-transcript case.
3. **Cache races between parallel sessions (Task 1).** Each session has its own cache file, and the
   helper writes it through a temp file and `mv`, so a reader never sees a half-written file.
4. **ccusage changes behaviour (Task 2).** The version is pinned. A future bump is a deliberate change.

**Ruled out**

- Building the cross-session view ourselves: ccusage already does it, counts subagents and matches
  the helper. Rebuilding it would add a second source of truth.
- Incremental parsing with byte offsets: the full scan is 0.5 s worst case and the cache removes it
  for unchanged sessions. Offsets add state that can go wrong for no measured gain.
- A cost figure in the status line: decision D2, tokens first.
- ccstatusline: Lars uses his own `warden-statusline`, and PR #441 is unmerged and has no model split.

---

### Task 1: Per-session token helper with cache

**Files:**
- Create: `bin/warden-session-tokens`
- Test: `bin/tests/warden-session-tokens.test.sh`
- Test fixtures: created inside the test script in a `mktemp -d` directory, not committed.

**Depends on:** none

**Model:** cheap tier → `sonnet`. Files, behaviour and tests are all stated below, and the task
touches one production file.

**Interfaces:**
- Produces: `warden-session-tokens [--json|--line] <transcript-path>`
  - `--json` (default) prints one JSON object:
    `{"models":[{"model":"claude-opus-5-5","input":N,"output":N,"cache_write":N,"cache_read":N}, ...],"agents":N}`
    with `models` sorted by `output` descending, and `<synthetic>` excluded.
  - `--line` prints one line, no trailing text after the newline, for example:
    `opus-5.5 out 330k  new 6.6M  cached 223M │ sonnet-5 out 753k  new 14M  cached 370M │ 46 agents`
  - Exit 0 with empty output when the transcript does not exist or has no usage lines.
  - Exit 2 with a usage message on stderr for a missing argument or an unknown flag.
  - Env `WARDEN_TOKENS_CACHE_DIR` overrides the cache directory (default `${TMPDIR:-/tmp}/warden-tokens`).

**Brief:**

The helper finds the session's files: the transcript `<dir>/<id>.jsonl` and every `*.jsonl` file
found recursively under `<dir>/<id>/`. The recursive search covers subagents at any spawn depth.
`agents` is the number of `agent-*.jsonl` files found under `<dir>/<id>/`.

It removes duplicates by `.message.id`, falling back to `.requestId`, then `.uuid`, when the id is
absent. For each key it keeps the **last** line in file order, so streamed responses report their
final `output_tokens`. Pre-filter with `grep -h '"usage"'` before `jq`; this halves the scan time.

The cache file is `<cache-dir>/<id>.json`. Its first field is a signature: one entry per found file
with path, size and modification time (`stat -f '%N %z %m'` on macOS, `stat -c '%n %s %Y'` as the
fallback). If the stored signature equals the current one, the helper prints from the cache and does
not run `jq` over transcripts. Otherwise it recomputes, writes `<cache-dir>/<id>.json.tmp.$$`, and
renames it over the cache file with `mv`.

`--line` formatting:
- Model label: drop the `claude-` prefix and any trailing `-YYYYMMDD` date, then turn the last
  `-N-M` version into `-N.M`. `claude-opus-5-5` → `opus-5.5`, `claude-sonnet-5` → `sonnet-5`,
  `claude-haiku-4-5-20251001` → `haiku-4.5`.
- `new` = `input + cache_write`. `cached` = `cache_read`.
- Numbers: under 1000 as is; under 1e6 as `k` rounded to an integer (`330500` → `330k`); from 1e6
  as `M` with one decimal under 10M and an integer from 10M (`6553189` → `6.6M`,
  `14026944` → `14M`, `222748511` → `223M`).
- Blocks join with ` │ `. The final `N agents` block appears only when `agents > 0`; use
  `1 agent` for one.

Test cases, each built from small hand-written JSONL fixtures:
1. A streamed response written as three lines with the same `message.id` and output 1, 5, 40:
   `--json` reports output 40, and input/cache counted once.
2. A session file plus two subagent files on different models: both models appear with the right
   sums, and `agents` is 2.
3. A `/btw`-style replay: a line in a subagent file with the same `message.id` as a parent line but a
   different `requestId` and `isSidechain: true`: the usage counts once.
4. A `<synthetic>` line is excluded from `models`.
5. `--line` output for the reference numbers above matches exactly:
   `sonnet-5 out 753k  new 14M  cached 370M │ opus-5.5 out 330k  new 6.6M  cached 223M │ haiku-4.5 out 696  new 72k  cached 393k │ 46 agents`
   Build this from a fixture with one line per model carrying those totals, plus 46 empty
   `agent-*.jsonl` files.
6. Cache hit and invalidation. Put a stub `jq` first on `PATH`. The stub appends one line to a
   marker file and then runs the real `jq` with the same arguments. Run the helper once and empty
   the marker file. Run it again: the output is identical and the marker file is still empty.
   Append a usage line to the transcript and run again: the marker file is no longer empty, and the
   output includes the new line's tokens.
7. Missing transcript path: exit 0 and empty stdout.
8. No argument: exit 2.

Test command: `bash bin/tests/warden-session-tokens.test.sh && shellcheck bin/warden-session-tokens bin/tests/warden-session-tokens.test.sh`

**Steps:**
- [ ] Write `bin/tests/warden-session-tokens.test.sh` with cases 1–8, in the style of
  `hooks/tests/guard-default-branch.test.sh` (`check` helper, `PASS`/`FAIL` lines, exit status).
- [ ] Run it and see every case fail because the helper does not exist.
- [ ] Write `bin/warden-session-tokens`: argument parsing, file discovery, deduplication, JSON output.
- [ ] Run the tests; cases 1–4, 7, 8 pass.
- [ ] Add the cache with signature and atomic write.
- [ ] Add `--line` formatting.
- [ ] Run the tests and see all 8 pass. Run `shellcheck` and see no warnings.
- [ ] Commit: `feat: add warden-session-tokens per-session token helper`.

### Task 2: `warden-usage` command for usage across all sessions

**Files:**
- Create: `bin/warden-usage`
- Test: `bin/tests/warden-usage.test.sh`

**Depends on:** none

**Model:** cheap tier → `sonnet`. One production file, behaviour and tests stated below.

**Brief:**

`warden-usage [day|week|month|session] [ccusage flags...]` runs
`npx -y ccusage@20.0.26 <report> --breakdown --offline [flags...]`.

- No first argument, or a first argument that starts with `-`: report `daily`.
- `day` → `daily`, `week` → `weekly`, `month` → `monthly`, `session` → `session`.
- `-h` or `--help` prints a usage text naming the four reports and one example
  (`warden-usage week --since 20260901`), then exits 0 without calling `npx`.
- An unknown first word exits 2 with the usage text on stderr.
- The command uses `exec` so ccusage's exit status is the command's exit status.
- The ccusage version sits in one variable at the top: `CCUSAGE_VERSION=20.0.26`.

Test cases use a stub `npx` on `PATH` that prints its arguments, one per line:
1. No argument → args are `-y ccusage@20.0.26 daily --breakdown --offline`.
2. `week --since 20260901` → `weekly`, then the fixed flags, then `--since 20260901`.
3. `--json` alone → report `daily` and `--json` passed through.
4. `bogus` → exit 2, stub not called.
5. `--help` → exit 0, stub not called.

Test command: `bash bin/tests/warden-usage.test.sh && shellcheck bin/warden-usage bin/tests/warden-usage.test.sh`

**Steps:**
- [ ] Write the test script with cases 1–5.
- [ ] Run it and see it fail.
- [ ] Write `bin/warden-usage`.
- [ ] Run the tests and see all 5 pass. Run `shellcheck` and see no warnings.
- [ ] Commit: `feat: add warden-usage wrapper around ccusage`.

### Task 3: Third status line, and the README

**Files:**
- Modify: `bin/warden-statusline` (header comment, and the end of the script after line 2)
- Modify: `README.md` (Layout table row for `bin/`, and the "Status line" section)
- Test: `bin/tests/warden-statusline.test.sh`

**Depends on:** Task 1 (calls `warden-session-tokens --line <transcript-path>`), Task 2 (README
documents `warden-usage`).

**Model:** standard tier → `sonnet`. It crosses a script and the README.

**Interfaces:**
- Consumes: `warden-session-tokens --line <transcript-path>` — prints one line or nothing, exit 0.

**Brief:**

`bin/warden-statusline` reads `.transcript_path` from its input with the existing `field` helper.
If the path is non-empty, it runs `"$(dirname "$0")/warden-session-tokens" --line "$path"` with
stderr discarded, and prints the result dimmed (`$DIM ... $RESET`) as its own line when non-empty.
Line 3 prints after line 2. The script's current `[ -n "$line" ] || exit 0` exits before line 3
when there are no rate limits; restructure the end so line 2 prints only when non-empty and line 3
still runs. Resolve the helper path through `$0` with `readlink -f` semantics so the script works
through the `~/.claude` symlink; reuse `ESC`, `DIM`, `RESET` and `field`, add no second copy.

Update the header comment to describe line 3. Update `README.md`:
- Layout row for `bin/`: list `warden-session-tokens` and `warden-usage` in the "Holds" column.
- "Status line" section: say three lines, add an example third line, explain that it counts the
  current session including subagents, per model, with `out`, `new` (input plus cache write) and
  `cached` (cache read). Add a short "Usage across sessions" paragraph with `warden-usage`,
  `warden-usage week`, `warden-usage month`, `warden-usage session`, and the install line
  `ln -s ~/dev/Warden/bin/warden-usage ~/.local/bin/warden-usage`.

Test cases, with `CONTEXT_STATUSLINE=/nonexistent` so line 1 uses the fallback:
1. Input JSON with `rate_limits.five_hour` and a `transcript_path` to a fixture with one usage line:
   output has three lines, and line 3 contains `out`.
2. Input JSON with no `rate_limits` and the same fixture: output has two lines (line 1 and the
   token line). This guards the early-exit restructure.
3. Input JSON with a `transcript_path` that does not exist and `rate_limits` present: output has
   exactly two lines, equal to the output before this change.
4. `warden-session-tokens` stubbed to exit 1 via a copy of the script dir: lines 1 and 2 still print.

Test command: `bash bin/tests/warden-statusline.test.sh && shellcheck bin/warden-statusline bin/tests/warden-statusline.test.sh`

**Steps:**
- [ ] Write the test script with cases 1–4.
- [ ] Run it and see cases 1, 2 fail.
- [ ] Change `bin/warden-statusline`.
- [ ] Run the tests and see all 4 pass. Run `shellcheck` and see no warnings.
- [ ] Update `README.md`.
- [ ] Commit: `feat: show per-session token usage as status line line 3`.

## Waves

| Wave | Tasks | Why |
|---|---|---|
| 1 | 1, 2 | Each task owns different files and neither depends on the other. |
| 2 | 3 | It calls the Task 1 helper and documents the Task 2 command. |

After the last wave, the session runs these checks itself before the final review:

1. **Acceptance check against ccusage.** For each of the 41 local sessions with a `subagents/`
   directory, compare `warden-session-tokens --json` with the matching entry of
   `npx -y ccusage@20.0.26 session --json --offline`. Pass: every model's input, output, cache write
   and cache read are equal.
2. **Live check.** Render the status line from this session's real input and confirm line 3 appears.
   Time a cold and a warm render of session `97dcc43a…`; pass is a warm render under 100 ms.
3. **`/clear` check (D3).** Confirm that `/clear` gives the status line a new `transcript_path`,
   which resets the count.

Then: the final review, the fix wave and the scoped re-review. A bounded change has no spec, so
`reconciling-specs` does not run. Lars installs `warden-usage` with the `ln -s` line, because
`~/.local/bin` is outside the repository.
