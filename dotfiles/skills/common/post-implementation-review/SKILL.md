---
name: post-implementation-review
description: Use when a feature implementation, refactor, or bugfix is complete
  and code changes need quality review before committing
---

# Post-Implementation Review

## Overview

Structured quality review for completed code changes. Run BEFORE committing or creating PRs.

**Core principle:** Simplify -> Verify -> Audit -> Learn.

**Announce at start:** "I'm using the post-implementation-review skill to review these changes."

## When to Use

- After completing a feature implementation
- After a significant refactor
- After fixing a complex bug with multi-file changes
- Before using finishing-a-development-branch or /commit

When NOT to use:
- Single-line fixes or typo corrections
- Documentation-only changes

## Workflow

### Step 1: Code Simplification

Dispatch `code-simplifier:code-simplifier` agent on recently modified **production** files.

- Focus scope: files changed in the current feature/branch
- Exclude test files
- Must NOT change functionality

### Step 2: Verify (Lint + Types + Tests)

Run the project's verification suite. **Must be green before proceeding.**

- If `flake.nix` exists, wrap all commands with `nix develop -c` (see `coding-standards` Nix Dev Shell section)
- Use `just lint` + `just test` if justfile exists
- Python: `ruff format --check` + `ruff check` + `pyright` + `pytest`
- JS/TS: `eslint` + `tsc` + `jest`/`vitest`
- If failures from Step 1: fix, re-run. Do not proceed until green.

### Step 3: Security Review

Invoke `/security-review` skill. Read changed files and audit against checklist:
secrets, input validation, SQL injection, auth, XSS, error handling, rate limiting, sensitive data exposure.

### Step 4: Continuous Learning (Optional)

Invoke `/continuous-learning` to extract reusable patterns.

**Important:** If a learned pattern is a language-specific coding standard (e.g., Python mocking pattern, async best practice), add it to the appropriate `coding-standards/references/` file (`python.md`, `typescript.md`, or `nix.md`) — NOT as a standalone learned skill. Standalone learned skills are for cross-cutting patterns (e.g., LangGraph interrupt pattern, SQLAlchemy migration gotcha).

## Quick Reference

| Step | Tool/Skill | Blocks Next? |
|------|-----------|-------------|
| 1. Simplify | code-simplifier:code-simplifier | Yes |
| 2. Verify | just lint + just test | Yes |
| 3. Security | /security-review | No |
| 4. Learn | /continuous-learning | No |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping verification after simplification | Always run lint+test — simplifier can introduce issues |
| Running security review on failing code | Fix lint/test first |
| Simplifying test files | Only simplify production code |
| Saving language-specific patterns as standalone skills | Add to coding-standards references instead |

## Integration

**Comes after:** Implementation complete, all original tests passing
**Comes before:** superpowers:finishing-a-development-branch, /commit
**Pairs with:** superpowers:requesting-code-review (complementary)

**When committing after review:** Invoke `/conventional-commits` skill for commit message format. For nixpkgs contributions, use nixpkgs-specific format instead (see `coding-standards/references/nix.md`).
