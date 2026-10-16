#!/usr/bin/env bash
# Tests for bin/warden-usage. Run: bash bin/tests/warden-usage.test.sh
# Exit 0 when every case passes.

set -uo pipefail

cmd="$(cd "$(dirname "$0")/.." && pwd)/warden-usage"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Stub npx: records its arguments (one per line) to NPX_STUB_LOG and exits 0.
# Tests never call the real npx or the network.
stubdir="$tmp/stub"
mkdir -p "$stubdir"
cat >"$stubdir/npx" <<'EOF'
#!/usr/bin/env bash
for a in "$@"; do printf '%s\n' "$a"; done >"$NPX_STUB_LOG"
exit 0
EOF
chmod +x "$stubdir/npx"

export PATH="$stubdir:$PATH"
export NPX_STUB_LOG="$tmp/npx-args.log"

fail=0

# check <name> <expected-exit> <expected-args-or-""> -- <warden-usage args...>
check() {
  local name="$1" want_exit="$2" want_args="$3"
  shift 3
  [ "$1" = "--" ] && shift
  rm -f "$NPX_STUB_LOG"
  local got_exit got_args
  "$cmd" "$@" >/dev/null 2>"$tmp/stderr"
  got_exit=$?
  if [ -f "$NPX_STUB_LOG" ]; then
    got_args="$(cat "$NPX_STUB_LOG")"
  else
    got_args="<stub not called>"
  fi
  if [ "$got_exit" = "$want_exit" ] && [ "$got_args" = "$want_args" ]; then
    printf 'PASS  %s\n' "$name"
  else
    printf 'FAIL  %s (want exit=%s args=%q, got exit=%s args=%q)\n' \
      "$name" "$want_exit" "$want_args" "$got_exit" "$got_args"
    fail=1
  fi
}

fixed='-y
ccusage@20.0.26'

check "no argument -> daily" 0 \
"$fixed
daily
--breakdown
--offline" \
  --

check "week --since -> weekly" 0 \
"$fixed
weekly
--breakdown
--offline
--since
20260901" \
  -- week --since 20260901

check "--json alone -> daily, flag passed through" 0 \
"$fixed
daily
--breakdown
--offline
--json" \
  -- --json

check "unknown first word -> exit 2, stub not called" 2 \
"<stub not called>" \
  -- bogus

check "--help -> exit 0, stub not called" 0 \
"<stub not called>" \
  -- --help

# --help must print usage naming the four reports and the example, without calling npx.
rm -f "$NPX_STUB_LOG"
help_out="$("$cmd" --help 2>&1)"
if printf '%s' "$help_out" | grep -q 'daily' \
  && printf '%s' "$help_out" | grep -q 'weekly' \
  && printf '%s' "$help_out" | grep -q 'monthly' \
  && printf '%s' "$help_out" | grep -q 'session' \
  && printf '%s' "$help_out" | grep -q 'warden-usage week --since 20260901'; then
  printf 'PASS  %s\n' "--help text names the four reports and example"
else
  printf 'FAIL  %s\n' "--help text names the four reports and example"
  fail=1
fi

# unknown first word must print usage text to stderr.
bogus_err="$("$cmd" bogus 2>&1 >/dev/null)"
if [ -n "$bogus_err" ]; then
  printf 'PASS  %s\n' "unknown first word prints usage to stderr"
else
  printf 'FAIL  %s\n' "unknown first word prints usage to stderr"
  fail=1
fi

exit "$fail"
