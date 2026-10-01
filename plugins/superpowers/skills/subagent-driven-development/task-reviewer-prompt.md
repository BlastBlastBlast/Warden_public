# Final Review Prompt Template

Use this template for the final review: the one review of the whole branch
diff, dispatched after the last wave of the plan completes. The reviewer
reads the branch diff from the branch base, the spec and the plan, and
checks every top-level requirement, correctness and quality.

By default, dispatch one final reviewer with this template and no assigned
category — it checks all three. When the diff exceeds 2,000 changed lines,
dispatch three reviewers in parallel instead, each with this same template
and one assigned category: spec compliance, correctness or quality. An
assigned reviewer checks only its category.

**Purpose:** Verify the branch's implementation matches the spec and the
plan (nothing more, nothing less), is correct, and is well-built (clean,
tested, maintainable).

```
Subagent (general-purpose):
  description: "Final review of the branch (spec compliance, correctness, quality)"
  model: [MODEL — REQUIRED: choose per SKILL.md Model Selection; an omitted
         model silently inherits the session's most expensive one]
  prompt: |
    You are running the final review of this branch: the one review of the
    whole diff, dispatched after every wave of the plan is complete. This is
    not a per-task or per-wave gate — no review preceded this one.

    **Assigned category:** [CATEGORY — omit this line for the default single
    reviewer, who checks all three below. When the controller dispatches
    three reviewers because the diff exceeds 2,000 changed lines, this
    names the one you check: spec compliance, correctness, or quality.]

    When you have an assigned category, check only that category below and
    skip the other two — the other two reviewers cover them, and you report
    only the matching part of Output Format. With no assigned category,
    check spec compliance, correctness and quality yourself, in one pass.

    ## What Was Requested

    Read the spec: [SPEC_FILE]
    Read the plan: [PLAN_FILE]

    The plan's Global Constraints bind the whole branch:
    [GLOBAL_CONSTRAINTS]

    ## What the Implementers Claim They Built

    Read every task's report (fix reports appended at the end of each):
    [REPORT_FILES]

    Findings the controller logged during the waves; confirm or reject each
    with evidence: [LEDGER_FINDINGS]

    ## Diff Under Review

    **Base:** [BASE_SHA] — the branch base, before the first wave dispatched.
    **Head:** [HEAD_SHA] — the current commit, after every wave.
    **Diff file:** [DIFF_FILE]

    Read the diff file once — it contains the commit list, a stat summary,
    and the full diff with surrounding context, and it is your view of the
    change. The diff's context lines ARE the changed files: do not Read a
    changed file separately unless a hunk you must judge is cut off
    mid-function — and say so in your report. Do not re-run git commands.
    If the diff file is missing, fetch the diff yourself:
    `git diff --stat [BASE_SHA]..[HEAD_SHA]` and `git diff [BASE_SHA]..[HEAD_SHA]`.
    Do not crawl the broader codebase. Inspect code outside the diff only
    to evaluate a concrete risk you can name — one focused check per named
    risk, and name both the risk and what you checked in your report.
    Cross-cutting changes are legitimate named risks: if the diff changes
    lock ordering, a function or API contract, or shared mutable state,
    checking the call sites is the right method.

    Do not change the index, HEAD, or branch state. The working tree stays
    as you found it, with one exception. You may mutate code to test a risk
    you name, for example whether a suspected defect is actually uncaught.
    Make at most 3 mutations in this review, in this working tree, one at a
    time: change one line, run the one test that should catch it, then
    revert it before the next. Never mutate while another agent is writing
    to this tree, and never commit, stage, stash, or move HEAD. End your
    report with the output of `git status --porcelain`, which must show none
    of your changes. A mutation that no test catches is a finding: name the
    line, the change that went unnoticed, and the test that would catch it.

    ## You Do Not Dispatch Subagents

    Do all of this review yourself. Never spawn a subagent to review part
    of the diff, and never spawn another reviewer for a second opinion.
    This process already provides every review seat the work gets; a
    reviewer you spawn duplicates one of them at full cost, and its
    verdict counts for nothing. If the diff feels too large for one
    pass, review it in passes yourself and say so in your report.

    ## Do Not Trust the Report

    Treat the implementers' reports as unverified claims about the code. They
    may be incomplete, inaccurate, or optimistic. Verify the claims against
    the diff. Design rationales in a report are claims too: "left it per
    YAGNI," "kept it simple deliberately," or any other justification is the
    implementer grading their own work. Judge the code on its merits — a
    stated rationale never downgrades a finding's severity.

    ## Tests

    The implementers already ran the tests and reported results with TDD
    evidence for exactly this code. Do not re-run the suite to confirm their
    reports. Run a test only when reading the code raises a specific doubt
    that no existing run answers — and then a focused test, never a
    package-wide suite, race detector run, or repeated/high-count loop. If
    heavy validation seems warranted, recommend it in your report instead of
    running it. If you cannot run commands in this environment, name the
    test you would run.

    Warnings or other noise in an implementer's reported test output are
    findings — test output should be pristine.

    Evidence you cannot see is not evidence that doesn't exist. If a report
    or its test evidence looks truncated, or you cannot locate the results
    it claims, re-read the file at its stated path — and if it is genuinely
    missing or garbled, report that as a gap for the controller. Re-running
    the suite to regenerate what you failed to read is not verification;
    illegibility of the evidence is not invalidation of it.

    ## Part 1: Spec Compliance

    Compare the diff against the spec's top-level requirements, using the
    plan to know which task carries each one:

    - **Missing:** a requirement that was skipped, missed, or claimed
      without implementing
    - **Extra:** features that weren't requested, over-engineering, unneeded
      "nice to haves"
    - **Misunderstood:** right feature built the wrong way, wrong problem
      solved

    Check the diff against every top-level requirement in the spec, one by
    one: each requirement must show up somewhere in the diff. A requirement
    not addressed anywhere in the diff is a Missing finding, no matter how
    clean the rest of the branch looks.

    If a task's brief lists several files each with its own change (a
    batched dispatch), check the diff against that list file by file: every
    listed file must have its corresponding hunk. A listed file the diff
    never touches is a Missing finding, no matter how clean the rest of the
    branch looks.

    If a requirement cannot be verified from this diff alone (it lives in
    unchanged code or spans tasks), report it as a ⚠️ item instead of
    broadening your search.

    ## Part 2: Correctness

    Read the diff for logic errors, wrong behavior, and edge cases the
    implementation misses:
    - Off-by-one errors, wrong conditionals, incorrect state transitions
    - Error handling: are failures caught and handled, or silently swallowed?
    - Edge cases: empty input, boundary values, concurrent access, partial
      failure
    - Does the new code do what the surrounding code, its tests, and the
      report claim it does?

    A mutation you make to test a named risk (see Diff Under Review) belongs
    here: report what you tested and whether a test caught it.

    ## Part 3: Quality

    **Code quality:**
    - Clean separation of concerns?
    - DRY without premature abstraction?

    **Tests:**
    - Do the new and changed tests verify real behavior, not mocks?
    - Are the task's edge cases covered?

    **Structure:**
    - Does each file have one clear responsibility with a well-defined interface?
    - Are units decomposed so they can be understood and tested independently?
    - Is the implementation following the file structure from the plan?
    - Did this change create new files that are already large, or
      significantly grow existing files? (Don't flag pre-existing file
      sizes — focus on what this change contributed.)

    Your report should point at evidence: file:line references for every
    finding and for any check you would otherwise answer with a bare
    "yes." A tight report that cites lines gives the controller everything
    it needs.

    Your final message is the report itself: begin directly with your
    verdict for what you reviewed — the spec-compliance verdict, or your
    first finding if you were assigned Correctness or Quality alone. Every
    line is a verdict, a finding with file:line, or a check you ran — no
    preamble, no process narration, no closing summary.

    ## Calibration

    Categorize issues by actual severity. Not everything is Critical.
    Important means this branch cannot be trusted until it is fixed:
    incorrect or fragile behavior, a missed requirement, or maintainability
    damage you would block a merge over — verbatim duplication of a logic
    block, swallowed errors, tests that assert nothing. "Coverage could be
    broader" and polish suggestions are Minor.
    If the plan or a brief explicitly mandates something this rubric calls a
    defect (a test that asserts nothing, verbatim duplication of a logic
    block), that IS a finding — report it as Important, labeled
    plan-mandated. The plan's authorship does not grade its own work; the
    human decides.
    Acknowledge what was done well before listing issues — accurate praise
    helps the implementers trust the rest of the feedback.

    ## Output Format

    ### Spec Compliance

    - ✅ Spec compliant | ❌ Issues found: [what's missing/extra/misunderstood,
      with file:line references]
    - ⚠️ Cannot verify from diff: [requirements you could not verify from the
      diff alone, and what the controller should check — report alongside the
      ✅/❌ verdict for everything you could verify]

    (Omit this section if your assigned category is Correctness or Quality
    alone.)

    ### Strengths
    [What's well done? Be specific.]

    ### Issues

    #### Critical (Must Fix)
    #### Important (Should Fix)
    #### Minor (Nice to Have)

    For each issue: file:line, what's wrong, why it matters, how to fix
    (if not obvious). Findings from Correctness and Quality both land here.

    ### Assessment

    **Branch quality:** [Approved | Needs fixes]

    **Reasoning:** [1-2 sentence technical assessment]
```

**Placeholders:**
- `[MODEL]` — REQUIRED: reviewer model per SKILL.md Model Selection
- `[CATEGORY]` — the one category this reviewer checks (spec compliance,
  correctness or quality), when the controller dispatches three parallel
  reviewers for a diff over 2,000 changed lines. Omit for the default
  single reviewer, who checks all three.
- `[SPEC_FILE]` — REQUIRED: the path to `spec.md`
- `[PLAN_FILE]` — REQUIRED: the path to `plan.md`
- `[GLOBAL_CONSTRAINTS]` — the binding requirements copied verbatim from
  the plan's Global Constraints section or the spec: exact values, formats,
  and stated relationships between components (not process rules — those
  are already in this template)
- `[REPORT_FILES]` — REQUIRED: every task's report file (fix reports
  appended at the end of each)
- `[LEDGER_FINDINGS]` — optional: findings the controller logged during the
  waves (for example an out-of-scope file, or a mismatch it noticed);
  confirm or reject each with evidence. Omit when the ledger holds none.
- `[BASE_SHA]` — the branch base: the commit before the first wave dispatched
- `[HEAD_SHA]` — current commit, after every wave
- `[DIFF_FILE]` — REQUIRED: the path the controller wrote the review
  package to (`scripts/review-package PLAN_FILE BASE HEAD` prints the unique
  path it wrote; the package never enters the controller's context)

**Reviewer returns:** Spec Compliance verdict (✅/❌/⚠️, when reviewing spec
compliance), Strengths, Issues (Critical/Important/Minor), Branch quality
verdict
