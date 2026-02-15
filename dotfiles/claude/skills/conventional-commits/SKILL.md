---
name: conventional-commits
description: Use when writing git commit messages, reviewing commits, or setting up commit conventions. Triggers on commit, git commit, commit message, changelog, semantic versioning.
---

# Conventional Commits v1.0.0-beta.2

Structured commit messages that enable automated changelogs and semantic versioning.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

## Quick Reference

| Type | Purpose | SemVer Impact |
|------|---------|---------------|
| `feat` | New feature (MUST use for new features) | MINOR bump |
| `fix` | Bug fix (MUST use for bug fixes) | PATCH bump |
| `docs` | Documentation only | None |
| `style` | Formatting, no code change | None |
| `refactor` | Neither fix nor feature | None |
| `perf` | Performance improvement | None |
| `test` | Adding/fixing tests | None |
| `chore` | Build, tooling, deps | None |
| Any + `BREAKING CHANGE` | Breaking API change | MAJOR bump |

## The 11 Specification Rules

1. Commits MUST be prefixed with a lowercase type (noun: `feat`, `fix`, etc.) followed by colon and space
2. `feat` MUST be used when a commit adds a new feature
3. `fix` MUST be used when a commit represents a bug fix
4. Optional scope MAY follow the type in parentheses: `fix(parser):`
5. Description MUST immediately follow the type/scope prefix
6. Longer body MAY follow after one blank line after description (may contain multiple paragraphs)
7. Footer MAY follow one blank line after body (or description if no body). Multiple footers allowed using `token: value` or `token #value` format
8. Breaking changes MUST be indicated at the very beginning of the footer or body section as uppercase `BREAKING CHANGE:` (or `BREAKING-CHANGE:`) followed by a space
9. A description MUST be provided after `BREAKING CHANGE:`
10. Types other than `feat` and `fix` MAY be used
11. `!` MAY be appended after type/scope (with or without scope: `feat!:` or `feat(scope)!:`) to draw attention to breaking change. `BREAKING CHANGE:` in footer MUST also be included when `!` is used

## Examples

**Simple feature:**
```
feat: add email notifications for order updates
```

**Scoped bug fix:**
```
fix(auth): prevent session fixation on login
```

**Breaking change with `!` and footer:**
```
refactor(api)!: remove deprecated /v1 endpoints

Migrate all clients to /v2 before upgrading.

BREAKING CHANGE: /v1/* endpoints have been removed. Use /v2/* instead.
```

**Breaking change without scope (using `!`):**
```
feat!: drop Node 14 support

BREAKING CHANGE: minimum Node version is now 16.
```

**Multiple footers:**
```
feat(parser): support nested array syntax

Arrays can now contain other arrays, enabling complex
data structures in configuration files.

Reviewed-by: Alice
Closes #245
```

## Common Mistakes

| Mistake | Correct |
|---------|---------|
| `Fixed bug in login` | `fix(auth): resolve null check on login` |
| `feat: Fix typo` | `fix: correct typo in README` (not a feature) |
| `BREAKING CHANGE` without footer format | Must be at start of footer/body: `BREAKING CHANGE: description` |
| `feat!:` without `BREAKING CHANGE` in footer | Rule 11: `!` requires `BREAKING CHANGE:` in footer too |
| Missing blank line before body | Body MUST be separated by one blank line |
| Scope with spaces `feat(my scope):` | Use hyphens: `feat(my-scope):` |
