---
name: source-authority
description: The tiers of authority we trust when checking current practice, and how to cite what
  was used. Use when about to state a version, flag, default, API signature or convention from
  memory, when sources disagree, when setting a convention others will follow, and for anything
  about Claude, Claude Code or the Anthropic API.
---

# Whose word carries weight

Highest first. A lower tier never overrides a higher one.

| Tier | Source | Authoritative for |
|---|---|---|
| 1 | Anthropic's own docs — `code.claude.com/docs`, `platform.claude.com/docs`, the `claude-code-guide` agent | Claude, Claude Code, skills, hooks, the API, model names and prices |
| 2 | This repo — its code, its tests, its git history, its `CLAUDE.md` | How we do it here |
| 3 | The maintainer's official docs, and Context7 for library docs | Library and framework APIs |
| 4 | The maintainer's repo — README, CHANGELOG, open issues, the source | Behaviour the docs do not cover |
| 5 | Community — Stack Overflow, blogs, forums, and model recall | A lead to confirm higher up |

## How to use them

- **Never answer from tier 5 alone.** It is a pointer. Confirm it higher, or say you could not.
- **Newer beats older inside a tier.** Check the date on a blog post and on a doc page.
- **The repo beats the internet on convention. The internet beats the repo on an external API.**
- **Say when sources disagree.** Name both, say which you followed and why.

## Citing

Name the source inline, at the point of use, in one line.

    Rebasing, not merging — per the repo's CONTRIBUTING.md (tier 2).
    `--force-with-lease` is the documented safe form (git-scm.com, tier 3).

When something could not be confirmed, say so and say what would settle it.

    Unconfirmed: the flag is absent from the v3 docs. The v2 docs use `--strict`.
