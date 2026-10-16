#!/usr/bin/env bash
# Tests for bin/warden-statusline. Run: bash bin/tests/warden-statusline.test.sh
# Exit 0 when every case passes.

set -uo pipefail

bindir="$(cd "$(dirname "$0")/.." && pwd)"
statusline="$bindir/warden-statusline"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export CONTEXT_STATUSLINE=/nonexistent
export WARDEN_TOKENS_CACHE_DIR="$tmp/cache"
mkdir -p "$WARDEN_TOKENS_CACHE_DIR"

fail=0
last_out=""
last_exit=0

# run <cmd> <input-json> — runs cmd with json on stdin, stores stdout in $last_out and its
# exit status in $last_exit. A non-zero exit here means Claude Code would blank the whole
# status line, so every case checks this in addition to line count/content.
run() {
  last_out=$(printf '%s' "$2" | "$1" 2>/dev/null)
  last_exit=$?
}

# check_exit_zero <name> — asserts the status line process exited 0.
check_exit_zero() {
  local name="$1"
  if [ "$last_exit" = "0" ]; then
    printf 'PASS  %s\n' "$name"
  else
    printf 'FAIL  %s (want exit 0, got %s)\n' "$name" "$last_exit"
    fail=1
  fi
}

# check_lines <name> <expected-line-count>  — checks line count of $last_out.
check_lines() {
  local name="$1" want="$2" got
  got=$(printf '%s\n' "$last_out" | wc -l | tr -d ' ')
  if [ "$got" = "$want" ]; then
    printf 'PASS  %s\n' "$name"
  else
    printf 'FAIL  %s (want %s lines, got %s)\n  out: %s\n' "$name" "$want" "$got" "$last_out"
    fail=1
  fi
}

# check_line_contains <name> <line-number> <substring>
check_line_contains() {
  local name="$1" n="$2" sub="$3" line
  line=$(printf '%s\n' "$last_out" | sed -n "${n}p")
  if printf '%s' "$line" | grep -q -- "$sub"; then
    printf 'PASS  %s\n' "$name"
  else
    printf 'FAIL  %s\n  line %s: %s\n' "$name" "$n" "$line"
    fail=1
  fi
}

# --- fixture: one real-shaped usage line ---------------------------------------------------------
fixture="$tmp/fixture.jsonl"
jq -nc '{type:"assistant",requestId:"req_1",uuid:"u1",message:{id:"msg_1",model:"claude-opus-5-5",
  usage:{input_tokens:2,output_tokens:236,cache_creation_input_tokens:20529,cache_read_input_tokens:34177}}}' \
  > "$fixture"

epoch_in_1h=$(( $(date +%s) + 3600 ))

payload() { # payload <transcript-path> <with-rate-limits:0|1>
  local tp="$1" with_rl="$2"
  if [ "$with_rl" = "1" ]; then
    jq -nc --arg tp "$tp" --argjson resets "$epoch_in_1h" \
      '{model:{display_name:"Opus 5.5"}, workspace:{current_dir:"/tmp/warden-test"},
        transcript_path:$tp, rate_limits:{five_hour:{used_percentage:7,resets_at:$resets}}}'
  else
    jq -nc --arg tp "$tp" \
      '{model:{display_name:"Opus 5.5"}, workspace:{current_dir:"/tmp/warden-test"}, transcript_path:$tp}'
  fi
}

# --- case 1: rate_limits present, transcript has usage -> 3 lines, line 3 has "out" --------------
run "$statusline" "$(payload "$fixture" 1)"
check_exit_zero "1: exits 0"
check_lines "1: rate_limits + usage fixture -> three lines" 3
check_line_contains "1b: line 3 contains \"out\"" 3 "out"

# --- case 2: no rate_limits, transcript has usage -> 2 lines (line 1 + token line) ----------------
run "$statusline" "$(payload "$fixture" 0)"
check_exit_zero "2: exits 0"
check_lines "2: no rate_limits + usage fixture -> two lines (guards early exit)" 2

# --- case 3: rate_limits present, transcript_path does not exist -> exactly two lines -------------
run "$statusline" "$(payload "$tmp/does-not-exist.jsonl" 1)"
check_exit_zero "3: exits 0"
check_lines "3: rate_limits + missing transcript -> two lines (unchanged)" 2

# --- case 4: warden-session-tokens stubbed to exit 1 -> lines 1 and 2 still print -----------------
stubbin="$tmp/stubbin"
mkdir -p "$stubbin"
cp "$bindir/warden-statusline" "$stubbin/warden-statusline"
cat > "$stubbin/warden-session-tokens" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
chmod +x "$stubbin/warden-statusline" "$stubbin/warden-session-tokens"
run "$stubbin/warden-statusline" "$(payload "$fixture" 1)"
check_exit_zero "4: exits 0"
check_lines "4: warden-session-tokens exits 1 -> lines 1 and 2 still print" 2

exit "$fail"
