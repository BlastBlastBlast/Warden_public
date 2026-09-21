---
name: writing-specs
description: Use when an approved intent.md exists for an architectural change and the next step is the requirements pass - turns it into a numbered RFC 2119 spec in controlled language. NOT for capturing what someone wants (use brainstorming), NOT for implementation planning (use writing-plans), and NOT for a bounded change, which goes straight to a plan.
---

# Writing Specs

You take one approved intent and produce the document the engineering work plans against.
The person who wrote the intent reviews this. They do not write it.

An intent says what someone wants. A spec says what the system will do about it, as
obligations someone can check.

**Announce at start:** "I'm using the writing-specs skill to turn the intent into requirements."

## Before Writing

1. **Read `intent.md` in full**, including its open questions. Every one of them gets answered
   here or carried forward by name.
2. **Read the code the change touches.** A requirement that ignores what exists is a
   requirement that gets rewritten during the build.
3. **Find what constrains this change** and apply it while you write, not as a review
   afterwards. Two kinds exist and they answer different questions.
   - **Rules and area guides** say how to write things in this repository: the root
     `CLAUDE.md` or `AGENTS.md`, and the nearest area `AGENTS.md` to the code you touch.
   - **Policy skills** say what the domain forbids — personal data, auth, money, brand,
     accessibility. Look in the project's own `.claude/skills/` as well as the ones you have.
     A project skill ships with the code and is the more likely place to find one.
4. **Where two constraints cannot both hold, do not pick one.** That is a flagged concern.

List what you applied under `## Constraints applied`, in both categories.

**A repository with a domain and no policy skill is a finding.** Say what the spec went
unconstrained by. A spec checked against nothing looks the same as a spec checked against
everything.

**A repository with no domain is not a finding.** Configuration, tooling and documentation
repositories have rules and no policy to have. Record that plainly and move on. Reporting an
empty section as a gap there teaches the reader to skip the section everywhere.

## Requirement Form

- **One capitalized keyword per requirement.** MUST, MUST NOT, SHOULD, SHOULD NOT, MAY. Two
  keywords in one sentence are two requirements. A keyword is normative only when capitalized.
- **Every requirement gets a stable number.** `REQ-7`. Sub-requirements are `REQ-7.1`.
  **Numbers are permanent** — never renumber one that an earlier commit contains. A dropped
  requirement becomes `REQ-7: withdrawn` with the reason.
- **Requirements nest.** `REQ-7` states the obligation. `REQ-7.1` and `REQ-7.2` state its
  parts. A sub-requirement carries its own keyword and never contradicts its parent.
- **Name the actor.** "Input MUST be validated" hides who validates. Write "The handler MUST
  validate the request body". In a repository whose product is prose, the actor is the file or
  the skill that carries the obligation.
- **State what proves it.** If you cannot name what would show a requirement met, it is a
  goal. Move it to Non-goals.
- **SHOULD needs an escape condition.** A SHOULD with no stated reason to deviate becomes a
  MUST in practice. Give the condition, or promote the requirement.

Group requirements by what they constrain, not by priority. Behavior, then data, then
interface, then operations.

Aim for **fewer than about ten top-level requirements**, with detail as sub-requirements. The
count is a signal, not a limit. A spec running past it usually means the change is two
changes — say so rather than growing one. A spec that genuinely needs more states the reason.

## Prose: ASD-STE100

Controlled language, so the document has one reading. The rules that bite hardest:

- One idea per sentence. About 20 words in a procedure, 25 in descriptive text.
- Active voice with the actor named.
- Simple tenses. "has been validated" becomes "the handler validates".
- **No semicolons at all.** Write two sentences.
- One term, one meaning, for the whole document. Never rotate synonyms for variety.
- Noun clusters capped at three words.
- No marketing adjectives. Delete them, or replace them with the measurement that earns them.

Full rules ship with this plugin at `skills/asd-ste100/references/writing-rules.md`. Worked
rewrites are at `skills/asd-ste100/examples/before-after.md`.

## The Document

Write to `docs/superpowers/changes/<YYYY-MM>-<slug>/spec.md`, beside the intent it answers.

```markdown
# Spec: <short name>

Intent: `intent.md`. Date: <YYYY-MM-DD>. Status: draft.

## Summary
<Three sentences. What this changes, for whom.>

## Requirements

### Behavior
**REQ-1** The <actor> MUST <observable behavior>.
  - **REQ-1.1** The <actor> MUST <part of it>.
  - **REQ-1.2** The <actor> MUST NOT <the excluded case>.
  *Proof: <the test or check that shows REQ-1 met>.*

### Data
**REQ-2** …

### Interface
**REQ-3** …

### Operations
**REQ-4** …

## Non-goals
<What this does not do, each with one line on why. Goals that failed the proof rule land here.>

## Constraints applied
<Rules and area guides, then policy skills. Name the files. When the repository has a domain
 and no policy skill, that belongs in Flagged concerns. When it has no domain, say so and stop.>

## Flagged concerns
<Each one: the two rules that conflict, the options, and who owns the decision.
 Never resolve one silently.>

## Open questions carried from intent
<Answered here, or restated as still open with who will answer.>

## Design notes
<How the change fits the existing system.>
```

## Never Resolve A Conflict Quietly

When a constraint from the intent contradicts a rule in the repository, or two rules
contradict each other, the spec says so and stops there. Give the two rules, the options with
their costs, and the name of the person who owns the decision.

Picking one and moving on is the failure this section exists to prevent. It buries a decision
your human partner would have made differently, in a document they will approve without
knowing the choice was made.

The same holds for a requirement that the intent does not support. Do not invent it. Raise it
as a question.

## Check It Before You Hand It Over

```bash
python3 skills/asd-ste100/scripts/ste-lint.py docs/superpowers/changes/<slug>/spec.md
```

Fix hard violations. Advisory findings are a prompt to reread the sentence, not a mandate — a
deliberate exception is fine when the document says why. **Show the output.**

Then read the spec back against the intent and answer these in your report:

- Does every open question from `intent.md` appear as answered or explicitly carried forward?
- Does the spec solve the stated problem, or a nearby problem that was easier?
- Can you name a proof for every MUST?

## The Approval Gate

Commit the spec as `docs: spec for <slug>`. Then hand the flagged concerns to the person who
wrote the intent. **They decide.** Wait for their ruling on each one and write the rulings into
the document.

Only after they approve the spec:

- **REQUIRED SUB-SKILL:** Use superpowers:writing-plans
- Do NOT invoke any other skill. writing-plans is the next step.

## Red Flags

| Thought | Reality |
|---------|---------|
| "These two constraints conflict, I'll take the sensible one" | That is the decision you are not allowed to make. Flag it. |
| "This requirement is obvious, it doesn't need a proof" | A requirement with no proof is a goal. Move it to Non-goals. |
| "I'll renumber so the sections read in order" | Numbers are permanent. A plan step, a test and a review finding all cite them. |
| "Fourteen requirements is fine, the change is big" | Usually it is two changes. Split it, or state why not. |
| "The intent didn't mention it but it clearly needs X" | Raise X as a question. A requirement with no source in the intent is your idea, not theirs. |
| "I'll write the plan too while I'm here" | The spec gets approved first. A plan for unapproved requirements is wasted work. |
