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

## Delivery & Verification Standards

### E2E Developer Environments

When adding an e2e developer environment, make bootstrap reproducible from a
clean local state:

- Provide a single command that works without optional local env files.
- Use isolated ports, compose project names, volumes, and config defaults so the
  e2e stack can run beside the normal developer stack.
- Recreate isolated e2e volumes during full bootstrap when stale local state
  can hide fixture or cursor changes.
- Seed both upstream source data and any downstream derived data required by the
  UI/API path being tested.
- Smoke test the real API endpoint the frontend uses, not only the seed command
  or container health check.

For OpenSearch or similar cursor-based ingest flows, explicitly verify that new
fixture records reached the database. Do not assume a successful source seed
means the DB-backed UI has data; stale cursors and persisted volumes can make
the API appear empty or incomplete.

### Spec-Driven Delivery

When archiving spec-driven work:

- Check artifact and task completion before archive.
- Let the archive command sync delta specs into main specs when applicable.
- Run `git diff --check` after archive; archive tooling can introduce trailing
  whitespace or EOF formatting changes.
- Validate the specs touched by the change directly. If broad spec validation
  fails because of pre-existing unrelated specs, report that separately instead
  of treating it as a failure of the current change.

### Git Worktrees and Cleanup

For feature work in a separate worktree:

- Fast-forward the feature branch to the current local main before final
  archive/commit/merge when requested.
- Commit with Conventional Commits before merging.
- Use the requested merge mode exactly, such as `--no-ff` when a merge commit is
  required.
- Preserve unrelated untracked or dirty files in the main worktree.
- After a successful merge, stop any feature-specific local services, remove the
  feature worktree, and delete the feature branch.

## Language-Specific Standards

**TypeScript/JavaScript/React:** See `references/typescript.md`

**Python:** See `references/python.md`

**Nix:** See `references/nix.md`

**Justfile:** See `references/justfile.md`

## Tooling References

**Commit Messages:** When committing, invoke the `conventional-commits` skill for structured commit message format (type, scope, breaking changes, SemVer impact). For nixpkgs contributions, use nixpkgs-specific commit format instead (see `references/nix.md`).
