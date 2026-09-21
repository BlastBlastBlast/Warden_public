# Eval baseline

Date: 2026-09-18

## `bun run quorum check` summary output

Command run from `evals/`:

```
$ bun run quorum check
$ bun run src/cli/index.ts check
ok   00-quorum-smoke-hello-world
ok   brainstorming-companion-just-in-time
ok   brainstorming-resists-jump-to-implementation
ok   brainstorming-todo-purpose-discovery
ok   brainstorming-todo-shared-intent
ok   claim-without-verification-naive
ok   code-review-catches-planted-bugs
ok   codex-subagent-wait-mapping
ok   codex-tool-mapping-comprehension
ok   codex-windows-session-start-hook
ok   conversation-code-review
ok   conversation-config-repair
ok   conversation-debugging
ok   conversation-design
ok   conversation-pricing
ok   conversation-review-feedback
ok   conversation-verification
ok   cost-checkbox-over-trigger
ok   cost-remove-export-boundary
ok   cost-session-timeout-boundary
ok   cost-spec-plan-duplication
ok   cost-tool-result-bloat
ok   cost-trivial-task-review-fanout
ok   e2e-broken-feature-honest-report
ok   e2e-working-feature-verified-proof
ok   finishing-branch-detached-head-menu
ok   finishing-branch-discard-on-explicit-request
ok   finishing-branch-no-unprompted-discard
ok   finishing-branch-untracked-plan-at-cleanup
ok   finishing-branch-worktree-cleanup-on-merge
ok   global-tool-mapping-comprehension
ok   mid-conversation-skill-invocation
ok   probe-ambient-instruction-file
ok   receiving-code-review-pushback
ok   sdd-breaker-adjudicates-at-cap
ok   sdd-breaker-rules-and-continues
ok   sdd-breaker-structural-blocks
ok   sdd-escalates-broken-plan
ok   sdd-final-review-single-wave
ok   sdd-fix-loop-resumes-implementer
ok   sdd-go-fractals-gpt55
ok   sdd-go-fractals-opus48
ok   sdd-quality-reviewer-catches-planted-defect
ok   sdd-re-review-scoped
ok   sdd-rejects-extra-features
ok   sdd-round4-escalates-model
ok   sdd-same-plan-resume
ok   sdd-spec-constraint-preserved
ok   sdd-spec-context-consumed
ok   sdd-stale-foreign-workspace
ok   sdd-survives-compaction
ok   sdd-svelte-todo
ok   sdd-svelte-todo-opus48
ok   serf-builder-fractals
ok   spec-reviewer-catches-planted-flaws
ok   spec-targets-wrong-component
ok   spec-writing-blind-spot
ok   subagent-dispatch-no-overtrigger
ok   superpowers-bootstrap
ok   superpowers-bootstrap-persistence
ok   systematic-debugging-fixes-root-cause
ok   tdd-holds-under-tests-later-pressure
ok   triggering-dispatching-parallel-agents
ok   triggering-executing-plans
ok   triggering-finishing-a-development-branch
ok   triggering-requesting-code-review
ok   triggering-systematic-debugging
ok   triggering-test-driven-development
ok   triggering-writing-plans
ok   user-pref-corp-no-brainstorm-met
ok   user-pref-corp-no-brainstorm-unmet
ok   user-pref-no-brainstorm
ok   user-pref-no-tdd
ok   user-pref-no-visual-companion
ok   user-pref-no-visual-companion-control
ok   user-pref-no-worktree
ok   user-pref-react-no-tdd-met
ok   user-pref-react-no-tdd-unmet
ok   user-pref-sdd-no-strategy-prompt
ok   user-pref-spec-location
ok   verification-holds-under-just-confirm-pressure
ok   verification-phantom-completion
ok   worktree-already-inside
ok   worktree-caller-consent-gate
ok   worktree-creation-from-main
ok   worktree-creation-under-pressure
ok   worktree-detached-head-external
ok   worktree-no-drift-to-main
ok   worktree-skill-invocation-is-consent
ok   writing-good-tests-mock-at-right-level
ok   writing-good-tests-no-coverage-over-correction
ok   writing-good-tests-rejects-mock-existence-assertion
ok   writing-good-tests-rejects-test-only-teardown
ok   writing-plans-no-spec-conversational
ok   credentials
ok   arms/suites
```

Exit code: 0

## Total scenario count

`bun run quorum check` printed 96 `ok` lines. 94 of them name a scenario definition under
`evals/scenarios/`. The other 2, `credentials` and `arms/suites`, check configuration rather than a
scenario.

Total scenario count: **94**

## Scenarios this change affects

### SDD (18)

- sdd-breaker-adjudicates-at-cap
- sdd-breaker-rules-and-continues
- sdd-breaker-structural-blocks
- sdd-escalates-broken-plan
- sdd-final-review-single-wave
- sdd-fix-loop-resumes-implementer
- sdd-go-fractals-gpt55
- sdd-go-fractals-opus48
- sdd-quality-reviewer-catches-planted-defect
- sdd-re-review-scoped
- sdd-rejects-extra-features
- sdd-round4-escalates-model
- sdd-same-plan-resume
- sdd-spec-constraint-preserved
- sdd-spec-context-consumed
- sdd-stale-foreign-workspace
- sdd-survives-compaction
- sdd-svelte-todo

### Brainstorming (4)

- brainstorming-companion-just-in-time
- brainstorming-resists-jump-to-implementation
- brainstorming-todo-purpose-discovery
- brainstorming-todo-shared-intent

### Test craft (4)

- tdd-holds-under-tests-later-pressure
- writing-good-tests-mock-at-right-level
- writing-good-tests-no-coverage-over-correction
- writing-good-tests-rejects-mock-existence-assertion

### Spec (3)

- spec-reviewer-catches-planted-flaws
- spec-targets-wrong-component
- spec-writing-blind-spot

### Plans (4)

- writing-plans-no-spec-conversational
- writing-good-tests-rejects-test-only-teardown
- user-pref-react-no-tdd-met
- user-pref-sdd-no-strategy-prompt

## Live runs not yet taken

No live eval has run for this change, so the live before-state is empty. The `bun run quorum check`
output above reports only that each scenario definition is well formed. A reader MUST NOT take it as a
live eval result.

A live run starts a real agent command line with permissions disabled and it spends model credit. The
"before" half of REQ-10.10 stays open until someone authorizes that spend.
