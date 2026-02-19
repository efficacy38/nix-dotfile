---
name: coding-standards
description: Universal coding standards, best practices, and patterns. Use when developing in any language — triggers on TypeScript, JavaScript, React, Node.js, Python, Nix, ruff, pyright, pytest, uv, flake.nix, justfile, just, recipes, and general code quality topics.
---

# Coding Standards & Best Practices

Universal coding standards applicable across all projects and languages.

## Nix Dev Shell

When `flake.nix` exists in the project (or a parent directory), **all dev/build/test commands must run inside the Nix dev shell**. If a required tool is not installed, use `nix shell nixpkgs#<pkg>` for one-off access or add it to `flake.nix` devShells.

```bash
# Single command
nix develop -c <command> <args>

# Multiple commands
nix develop --command bash -c "command1 && command2"

# One-off tool access (no flake needed)
nix shell nixpkgs#jq -c jq '.key' file.json

# Legacy shell.nix
nix-shell --run "cargo build"
```

**Do NOT wrap Nix management commands** in dev shell — run these directly:
`nix build`, `nix flake check`, `nix fmt`, `nix develop`, `nh os switch`

**Decision:** Detect flake first (Glob for `**/flake.nix`). If present, wrap dev commands. If a tool is missing and no flake exists, use `nix shell nixpkgs#<pkg>` or suggest creating a `flake.nix`.

## Code Quality Principles

### 1. Readability First
- Code is read more than written
- Clear variable and function names
- Self-documenting code preferred over comments
- Consistent formatting

### 2. KISS (Keep It Simple, Stupid)
- Simplest solution that works
- Avoid over-engineering
- No premature optimization
- Easy to understand > clever code

### 3. DRY (Don't Repeat Yourself)
- Extract common logic into functions
- Create reusable components
- Share utilities across modules
- Avoid copy-paste programming

### 4. YAGNI (You Aren't Gonna Need It)
- Don't build features before they're needed
- Avoid speculative generality
- Add complexity only when required
- Start simple, refactor when needed

## API Design Standards

### REST API Conventions

```
GET    /api/resources              # List all
GET    /api/resources/:id          # Get specific
POST   /api/resources              # Create new
PUT    /api/resources/:id          # Update (full)
PATCH  /api/resources/:id          # Update (partial)
DELETE /api/resources/:id          # Delete

# Query parameters for filtering
GET /api/resources?status=active&limit=10&offset=0
```

### Response Format

Maintain consistent response structures across APIs:

- Success responses include `data` and optional `meta` (pagination)
- Error responses include `error` message and appropriate HTTP status
- Use schema validation at API boundaries (Zod, Pydantic, etc.)

## Comments & Documentation

### When to Comment

```
# Explain WHY, not WHAT
# Use exponential backoff to avoid overwhelming the API during outages
delay = min(1000 * (2 ** retry_count), 30000)

# Deliberately using mutation here for performance with large arrays
items.append(new_item)
```

Do NOT comment obvious code (`# increment counter`, `# set name`).

### Public API Documentation

- TypeScript/JavaScript: JSDoc with `@param`, `@returns`, `@throws`, `@example`
- Python: Docstrings (Google style or NumPy style), type hints

## Code Smell Detection

Watch for these anti-patterns:

### 1. Long Functions
Functions > 50 lines should be split into smaller, focused functions.

### 2. Deep Nesting
Use early returns / guard clauses instead of 5+ levels of nesting.

### 3. Magic Numbers
Use named constants instead of unexplained literals.

## Testing Standards

### Test Structure (AAA Pattern)

```
# Arrange — set up test data and preconditions
# Act — execute the code under test
# Assert — verify the result
```

### Test Naming

Use descriptive names that explain the scenario and expected outcome:
- `test_returns_empty_array_when_no_markets_match_query`
- `test_throws_error_when_api_key_is_missing`
- `test_falls_back_to_substring_search_when_cache_unavailable`

Avoid vague names like `test_works` or `test_search`.

## Language-Specific Standards

**TypeScript/JavaScript/React:** See `references/typescript.md`

**Python:** See `references/python.md`

**Nix:** See `references/nix.md`

**Justfile:** See `references/justfile.md`

## Tooling References

**Commit Messages:** When committing, invoke the `conventional-commits` skill for structured commit message format (type, scope, breaking changes, SemVer impact). For nixpkgs contributions, use nixpkgs-specific commit format instead (see `references/nix.md`).
