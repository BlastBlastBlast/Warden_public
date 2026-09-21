# Pull request body template

Use this when the repository has no template of its own. When it has one, that
one wins — fill every section of it and use this only to judge whether your
answers are specific enough.

Generate the body. Do not ask your human partner to write it. Show them the
result before the request opens.

---

## What this changes

<!-- One paragraph, for someone who has never opened this repository. No class
     names, no file paths, no internal vocabulary. If a reader cannot tell what
     is different for them after this lands, rewrite it. -->

## Why

<!-- The problem this solves, from the intent. What could not be done before.
     "Improving X" is not a reason. What broke, or what could not happen? -->

## What it does not do

<!-- Scope boundaries. The things a reviewer might expect to find here and
     will not. Taken from the spec's Non-goals where one exists. -->

## Requirements satisfied

<!-- Identifiers only, where a spec exists: REQ-3, REQ-4.2, REQ-7.
     The spec travels in the branch, so the reviewer can read them there.
     Omit this section entirely for a change with no spec. -->

## How it was verified

<!-- The commands you ran and what they printed. Not "tests pass" — the
     command and its result. Name anything you could not run, and why.
     An unverifiable claim is worse than an open question. -->

## Decisions a reviewer should check

<!-- Every ruling made on your human partner's behalf during the build, and
     what each one costs if it is wrong. Where a spec was reconciled, the
     divergences and their rulings go here. This is the section a reviewer
     reads first when something looks odd later. -->

## Risks

<!-- What this could break, worst first. Empty is an acceptable answer only
     when you can say why. -->

---

## Rules for filling it

- **No placeholder survives.** "TBD", "TODO", and a heading with nothing under
  it are all placeholders. A section that genuinely does not apply gets one
  line saying why, or gets deleted.
- **Controlled language.** One idea per sentence. Active voice. No semicolons.
  Check it: `python3 skills/asd-ste100/scripts/ste-lint.py <body-file>`
- **The first paragraph carries the whole thing.** Most reviewers read that and
  the diff. Everything else is for the reviewer who comes back in six months.
- **Never describe work that did not ship.** Where a spec exists, write the body
  from the reconciled spec, after `superpowers:reconciling-specs` has run. A body
  written from a stale spec describes software nobody built.
