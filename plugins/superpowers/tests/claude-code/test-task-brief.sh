#!/usr/bin/env bash
# Tests for task-brief: it accepts a plain task ID (REQ-9.4) and ends the
# brief at the next heading whose level is the same as or higher than the
# task heading -- a following task heading or a Waves section. It must also
# keep extracting the old, dotted, sliced `Task <slice>.<task>` form so plans
# written before this change still work.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SDD_SCRIPTS="$REPO_ROOT/skills/subagent-driven-development/scripts"

FAILURES=0
TEST_ROOT=""

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

main() {
    echo "=== Test: task-brief ==="

    TEST_ROOT="$(mktemp -d)"
    trap cleanup EXIT

    local plan="$TEST_ROOT/plan.md"
    cat > "$plan" <<'PLAN'
# Fixture Plan

### Task 1: Alpha

Alpha body text.

### Task 2: Bravo

Bravo body text before the fence.

```text
### Task 9.9: Fake task inside a fence

Fake body inside a fence: this heading must not start or end a brief.
```

Bravo body text after the fence.

### Task 3: Charlie

Charlie body text.

## Waves

| Wave | Tasks |
|------|-------|
| 1    | 1, 2  |
| 2    | 3     |
PLAN

    local old_plan="$TEST_ROOT/old-plan.md"
    cat > "$old_plan" <<'PLAN'
# Old-Form Plan

## Slice 1: First slice

### Task 1.1: First thing

Do the first thing.

### Task 1.2: Second thing

Do the second thing.

## Slice 2: Second slice
PLAN

    # --- 2's brief holds its own body and text after the fence ---
    local out_2="$TEST_ROOT/task-2-brief.md"
    "$SDD_SCRIPTS/task-brief" "$plan" 2 "$out_2" >/dev/null
    local body_2
    body_2="$(cat "$out_2")"

    if [[ "$body_2" == *"Bravo body text before the fence."* \
        && "$body_2" == *"Bravo body text after the fence."* ]]; then
        pass "brief for 2 contains Task 2's body and text after fence"
    else
        fail "brief for 2 contains Task 2's body and text after fence"
        echo "    got: $body_2"
    fi

    # --- 2's brief does not contain Task 3's body (fenced heading is inside a fence, so included) ---
    if [[ "$body_2" != *"Charlie body text."* ]]; then
        pass "brief for 2 does not contain Task 3's body"
    else
        fail "brief for 2 does not contain Task 3's body"
        echo "    got: $body_2"
    fi

    # --- 3's brief ends before Waves section ---
    local out_3="$TEST_ROOT/task-3-brief.md"
    "$SDD_SCRIPTS/task-brief" "$plan" 3 "$out_3" >/dev/null
    local body_3
    body_3="$(cat "$out_3")"

    if [[ "$body_3" == *"Charlie body text."* && "$body_3" != *"## Waves"* ]]; then
        pass "brief for 3 ends before Waves section"
    else
        fail "brief for 3 ends before Waves section"
        echo "    got: $body_3"
    fi

    # --- the heading inside the fence does not start a brief of its own ---
    local rc=0
    "$SDD_SCRIPTS/task-brief" "$plan" 9.9 "$TEST_ROOT/task-9.9-brief.md" >/dev/null 2>&1 || rc=$?
    if [[ "$rc" -eq 3 ]]; then
        pass "the fenced heading does not start a brief"
    else
        fail "the fenced heading does not start a brief"
        echo "    exit: $rc"
    fi

    # --- the old, dotted, sliced Task 1.2 form still extracts ---
    local out_old="$TEST_ROOT/task-1.2-old-brief.md"
    "$SDD_SCRIPTS/task-brief" "$old_plan" 1.2 "$out_old" >/dev/null
    local body_old
    body_old="$(cat "$out_old")"

    if [[ "$body_old" == *"Do the second thing."* && "$body_old" != *"Do the first thing."* && "$body_old" != *"## Slice 2"* ]]; then
        pass "the old form 'Task 1.2' still extracts"
    else
        fail "the old form 'Task 1.2' still extracts"
        echo "    got: $body_old"
    fi

    echo ""
    if [[ "$FAILURES" -ne 0 ]]; then
        echo "FAILED: $FAILURES assertion(s)."
        exit 1
    fi
    echo "PASS"
}

main "$@"
