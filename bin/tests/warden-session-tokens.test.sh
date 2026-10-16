#!/usr/bin/env bash
# Tests for bin/warden-session-tokens. Run: bash bin/tests/warden-session-tokens.test.sh
# Exit 0 when every case passes.

set -uo pipefail

helper="$(cd "$(dirname "$0")/.." && pwd)/warden-session-tokens"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export WARDEN_TOKENS_CACHE_DIR="$tmp/cache"
proj="$tmp/proj"
mkdir -p "$proj" "$WARDEN_TOKENS_CACHE_DIR"

fail=0

check_out() { # check_out <name> <expected-stdout> -- <cmd...>
  local name="$1" want="$2"; shift 2
  local got
  got=$("$@" 2>/dev/null)
  if [ "$got" = "$want" ]; then
    printf 'PASS  %s\n' "$name"
  else
    printf 'FAIL  %s\n  want: %s\n  got:  %s\n' "$name" "$want" "$got"
    fail=1
  fi
}

check_exit() { # check_exit <name> <expected-exit> <cmd...>
  local name="$1" want="$2"; shift 2
  "$@" >/dev/null 2>&1
  local got=$?
  if [ "$got" = "$want" ]; then
    printf 'PASS  %s\n' "$name"
  else
    printf 'FAIL  %s (want %s, got %s)\n' "$name" "$want" "$got"
    fail=1
  fi
}

check_str() { # check_str <name> <expected> <actual>
  local name="$1" want="$2" got="$3"
  if [ "$got" = "$want" ]; then
    printf 'PASS  %s\n' "$name"
  else
    printf 'FAIL  %s\n  want: %s\n  got:  %s\n' "$name" "$want" "$got"
    fail=1
  fi
}

# usage_line <model> <msg-id> <request-id> <input> <output> <cache-write> <cache-read> [sidechain]
usage_line() {
  local model="$1" id="$2" reqid="$3" input="$4" output="$5" cwrite="$6" cread="$7" sidechain="${8:-false}"
  jq -nc --arg model "$model" --arg id "$id" --arg reqid "$reqid" \
    --argjson input "$input" --argjson output "$output" --argjson cwrite "$cwrite" --argjson cread "$cread" \
    --argjson sidechain "$sidechain" \
    '{type:"assistant", message:{id:$id, model:$model, usage:{input_tokens:$input, output_tokens:$output,
      cache_creation_input_tokens:$cwrite, cache_read_input_tokens:$cread}}, requestId:$reqid,
      isSidechain:$sidechain}'
}

# --- case 1: streamed response, same message.id, last output_tokens wins ---------------------
case1="$proj/case1.jsonl"
{
  usage_line "claude-sonnet-5" "msg_1" "req_1" 10 1 2 3
  usage_line "claude-sonnet-5" "msg_1" "req_1" 10 5 2 3
  usage_line "claude-sonnet-5" "msg_1" "req_1" 10 40 2 3
} > "$case1"
want1='{"models":[{"model":"claude-sonnet-5","input":10,"output":40,"cache_write":2,"cache_read":3}],"agents":0}'
check_out "1: streamed response keeps last output, counts input/cache once" "$want1" \
  "$helper" --json "$case1"

# --- case 2: session file plus two subagent files on different models -------------------------
case2="$proj/case2.jsonl"
mkdir -p "$proj/case2/subagents"
usage_line "claude-opus-5-5" "m_main" "req_main" 100 200 10 20 > "$case2"
usage_line "claude-sonnet-5" "m_a1" "req_a1" 5 50 1 2 > "$proj/case2/subagents/agent-1.jsonl"
usage_line "claude-sonnet-5" "m_a2" "req_a2" 7 70 3 4 > "$proj/case2/subagents/agent-2.jsonl"
want2='{"models":[{"model":"claude-opus-5-5","input":100,"output":200,"cache_write":10,"cache_read":20},{"model":"claude-sonnet-5","input":12,"output":120,"cache_write":4,"cache_read":6}],"agents":2}'
check_out "2: main plus two subagent files sum correctly, agents is 2" "$want2" \
  "$helper" --json "$case2"

# --- case 3: /btw-style replay, same message.id, different requestId, isSidechain ---------------
case3="$proj/case3.jsonl"
mkdir -p "$proj/case3/subagents"
usage_line "claude-sonnet-5" "m_shared" "req_parent" 50 100 5 6 false > "$case3"
usage_line "claude-sonnet-5" "m_shared" "req_child" 999 999 999 999 true > "$proj/case3/subagents/agent-x.jsonl"
want3='{"models":[{"model":"claude-sonnet-5","input":999,"output":999,"cache_write":999,"cache_read":999}],"agents":1}'
check_out "3: shared message.id across sidechain counts once" "$want3" \
  "$helper" --json "$case3"

# --- case 4: <synthetic> line excluded -----------------------------------------------------------
case4="$proj/case4.jsonl"
{
  usage_line "claude-sonnet-5" "m_real" "req_real" 10 20 1 2
  usage_line "<synthetic>" "m_synth" "req_synth" 500 500 500 500
} > "$case4"
want4='{"models":[{"model":"claude-sonnet-5","input":10,"output":20,"cache_write":1,"cache_read":2}],"agents":0}'
check_out "4: <synthetic> model excluded from models" "$want4" \
  "$helper" --json "$case4"

# --- case 5: --line formatting against reference numbers, with 46 agents ------------------------
case5="$proj/case5.jsonl"
mkdir -p "$proj/case5/subagents"
{
  usage_line "claude-sonnet-5" "m_sonnet" "req_sonnet" 4680 752910 14026944 369673759
  usage_line "claude-opus-5-5" "m_opus" "req_opus" 2116 330500 6553189 222748511
  usage_line "claude-haiku-4-5-20251001" "m_haiku" "req_haiku" 66 696 72072 393300
} > "$case5"
for i in $(seq 1 46); do : > "$proj/case5/subagents/agent-$i.jsonl"; done
want5='sonnet-5 out 753k  new 14M  cached 370M │ opus-5.5 out 330k  new 6.6M  cached 223M │ haiku-4.5 out 696  new 72k  cached 393k │ 46 agents'
check_out "5: --line matches reference numbers exactly" "$want5" \
  "$helper" --line "$case5"

# --- case 6: cache hit and invalidation -----------------------------------------------------------
stubdir="$tmp/stubbin"
mkdir -p "$stubdir"
real_jq=$(command -v jq)
marker="$tmp/jq-called"
: > "$marker"
cat > "$stubdir/jq" <<EOF
#!/usr/bin/env bash
echo called >> "$marker"
exec "$real_jq" "\$@"
EOF
chmod +x "$stubdir/jq"

case6="$proj/case6.jsonl"
usage_line "claude-sonnet-5" "m_first" "req_first" 1 2 0 0 > "$case6"

PATH="$stubdir:$PATH" out1=$("$helper" --json "$case6")
: > "$marker" # first run is a cache miss by design; reset the marker before testing the hit

PATH="$stubdir:$PATH" out2=$("$helper" --json "$case6")
check_str "6: cache hit reproduces identical output" "$out1" "$out2"

marker_size=$(wc -c < "$marker" | tr -d ' ')
if [ "$marker_size" = "0" ]; then
  printf 'PASS  %s\n' "6: cache hit calls no jq"
else
  printf 'FAIL  %s (marker has %s bytes)\n' "6: cache hit calls no jq" "$marker_size"
  fail=1
fi

usage_line "claude-sonnet-5" "m_second" "req_second" 3 4 0 0 >> "$case6"
PATH="$stubdir:$PATH" out3=$("$helper" --json "$case6")

marker_size=$(wc -c < "$marker" | tr -d ' ')
if [ "$marker_size" != "0" ]; then
  printf 'PASS  %s\n' "6: cache invalidation calls jq again"
else
  printf 'FAIL  %s (marker still empty)\n' "6: cache invalidation calls jq again"
  fail=1
fi

want6='{"models":[{"model":"claude-sonnet-5","input":4,"output":6,"cache_write":0,"cache_read":0}],"agents":0}'
check_str "6: cache invalidation output includes the new line" "$want6" "$out3"

# --- case 7: missing transcript path --------------------------------------------------------------
missing="$proj/does-not-exist.jsonl"
check_out "7: missing transcript prints empty stdout" "" "$helper" --json "$missing"
check_exit "7: missing transcript exits 0" 0 "$helper" --json "$missing"

# --- case 8: no argument ---------------------------------------------------------------------------
check_exit "8: no argument exits 2" 2 "$helper"
stderr_out="$tmp/stderr"
"$helper" 2>"$stderr_out" >/dev/null
if [ -s "$stderr_out" ]; then
  printf 'PASS  %s\n' "8: no argument writes a usage message to stderr"
else
  printf 'FAIL  %s\n' "8: no argument writes a usage message to stderr"
  fail=1
fi

# --- case 9: a half-written last line (Claude Code appending to a live transcript) ----------------
case9="$proj/case9.jsonl"
{
  usage_line "claude-sonnet-5" "m_good1" "req_good1" 10 20 1 2
  # Deliberately truncated mid-object: contains the "usage" substring (passes the grep pre-filter)
  # but is not valid JSON.
  printf '%s' '{"type":"assistant","message":{"id":"m_broken","model":"claude-sonnet-5","usage":{"input_tok'
  printf '\n'
} > "$case9"
want9='{"models":[{"model":"claude-sonnet-5","input":10,"output":20,"cache_write":1,"cache_read":2}],"agents":0}'
check_out "9: a half-written line is dropped, valid lines still counted" "$want9" \
  "$helper" --json "$case9"

# --- case 10: a usage line with none of message.id, requestId or uuid -----------------------------
case10="$proj/case10.jsonl"
{
  usage_line "claude-opus-5-5" "m_good2" "req_good2" 100 200 10 20
  printf '%s\n' '{"type":"assistant","message":{"model":"claude-opus-5-5","usage":{"input_tokens":999,"output_tokens":999,"cache_creation_input_tokens":999,"cache_read_input_tokens":999}}}'
  usage_line "claude-opus-5-5" "m_good3" "req_good3" 5 7 0 0
} > "$case10"
want10='{"models":[{"model":"claude-opus-5-5","input":105,"output":207,"cache_write":10,"cache_read":20}],"agents":0}'
check_out "10: a line with no message.id/requestId/uuid is dropped, not fatal" "$want10" \
  "$helper" --json "$case10"

exit "$fail"
