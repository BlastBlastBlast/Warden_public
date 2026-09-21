#!/usr/bin/env bash
# Run every test. Exit non-zero when any test fails. REQ-9.3.
set -uo pipefail
TESTS_DIR=$(cd -P "$(dirname "$0")" && pwd)

total=0
failed=0
for t in "$TESTS_DIR"/*_*.sh; do
  name=$(basename "$t")
  total=$((total + 1))
  printf '%s\n' "$name"
  if bash "$t"; then
    :
  else
    failed=$((failed + 1))
  fi
done

printf '\n%d tests, %d failed\n' "$total" "$failed"
[ "$failed" -eq 0 ]
