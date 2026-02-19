# Justfile Standards

Standards for writing justfiles using [just](https://github.com/casey/just) — a command runner, not a build system. Referenced from the main `coding-standards` skill.

## When to Use Just

| Use this when... | Use alternative when... |
|------------------|------------------------|
| Creating project-specific task automation | Need build system with incremental compilation → Make |
| Writing cross-platform project commands | Need tool version management bundled → mise tasks |
| Adding shebang recipes (Python, Node, etc.) | Simple one-off shell scripts → Bash directly |
| Setting up CI/CD with just recipes | Project already has extensive Makefile |
| Standardizing recipes across projects | Need Docker-specific workflows → docker-compose |

## Recipe Naming Conventions

| Rule | Pattern | Examples |
|------|---------|---------|
| Hyphen-separated | `word-word` | `test-unit`, `format-check` |
| Verb-first (actions) | `verb-object` | `lint`, `build`, `clean` |
| Noun-first (categories) | `noun-verb` | `db-migrate`, `docs-serve` |
| Private prefix | `_name` | `_generate-secrets`, `_setup` |
| `-check` suffix | Read-only verification | `format-check` |
| `-fix` suffix | Auto-correction | `lint-fix`, `check-fix` |
| `-watch` suffix | Watch mode | `test-watch`, `docs-watch` |
| Modifiers after base | `base-modifier` | `build-release` (not `release-build`) |

## Semantic Workflow Recipes

Standard composite recipes with defined meanings:

| Recipe | Composition | Purpose |
|--------|-------------|---------|
| `check` | `format-check` + `lint` + `typecheck` | Code quality only, no tests |
| `pre-commit` | `format-check` + `lint` + `typecheck` + `test-unit` | Fast, non-mutating validation |
| `ci` | `check` + `test-coverage` + `build` | Full CI simulation |
| `clean` | Remove build artifacts | Partial cleanup |
| `clean-all` | `clean` + remove deps/caches | Full cleanup |

## Golden Template

```just
# Project — task runner
# Run `just` or `just help` to see available recipes

####################
# Settings
####################

# set dotenv-load
# set positional-arguments

####################
# Variables
####################

# project := "my-project"

####################
# Metadata
####################

# Default recipe - show help
default:
    @just --list

# Show available recipes with descriptions
help:
    @just --list --unsorted

####################
# Development
####################

# Start development environment
dev:
    # bun run dev / uv run uvicorn app:app --reload

# Build for production
build:
    # bun run build / cargo build --release

# Clean build artifacts
clean:
    # rm -rf dist build .next

####################
# Code Quality
####################

# Run linter (read-only)
lint *args:
    # uv run ruff check {{args}} / bun run lint {{args}}

# Auto-fix lint issues
lint-fix:
    # uv run ruff check --fix . / bun run lint:fix

# Format code (mutating)
format *args:
    # uv run ruff format {{args}} / bun run format {{args}}

# Check formatting without modifying (non-mutating)
format-check *args:
    # uv run ruff format --check {{args}}

# Type checking
# typecheck:
#     bunx tsc --noEmit / uv run pyright

####################
# Testing
####################

# Run all tests
test *args:
    # uv run pytest {{args}} / bun test {{args}}

# Run unit tests only
# test-unit *args:
#     uv run pytest -m unit {{args}}

####################
# Workflows
####################

# Pre-commit checks (fast, non-mutating)
pre-commit: format-check lint test
    @echo "Pre-commit checks passed"

# Full CI simulation
ci: format-check lint test build
    @echo "CI simulation passed"
```

### Section Structure

Organize recipes into standard sections with `####################` dividers:

| Section | Recipes | Purpose |
|---------|---------|---------|
| **Metadata** | `default`, `help` | Discovery and navigation |
| **Development** | `dev`, `build`, `clean`, `start`, `stop` | Core dev cycle |
| **Code Quality** | `lint`, `lint-fix`, `format`, `format-check`, `typecheck` | Code standards |
| **Testing** | `test`, `test-unit`, `test-integration`, `test-e2e`, `test-watch` | Test tiers |
| **Workflows** | `check`, `pre-commit`, `ci` | Composite operations |
| **Dependencies** | `install`, `update` | Package management |
| **Database** | `db-migrate`, `db-seed`, `db-reset` | Data operations |
| **Documentation** | `docs`, `docs-serve` | Project docs |

## Essential Syntax

### Variables and Interpolation

```just
version := "1.0.0"
project := env('PROJECT_NAME', 'default')
git_hash := `git rev-parse --short HEAD`

info:
    @echo "Project: {{project}} v{{version}}"
```

- `:=` for assignment, `{{variable}}` for interpolation
- Backticks for shell command substitution
- `env(key, default)` for environment variables with fallback

### String Types

```just
single := 'literal \n stays'       # No escape processing
double := "newline \n works"        # Escape sequences processed
cmd    := `git describe --tags`     # Shell command substitution
multi  := '''
    line one
    line two
'''                                 # Indented triple-quote (auto-unindents)
```

### Parameters

```just
# Required parameter
build target:
    cargo build --package {{target}}

# Default value
test mode="debug":
    cargo test --profile {{mode}}

# Variadic: one or more (+)
backup +files:
    tar -czf backup.tar.gz {{files}}

# Variadic: zero or more (*)
test *args:
    cargo test {{args}}

# Default for variadic
lint *flags="-q":
    ruff check {{flags}} .

# Export as environment variable ($)
run $PORT="8080":
    ./server --port $PORT
```

### Dependencies

```just
# Simple (runs build and test first)
deploy: build test
    ./deploy.sh

# Dependency with arguments
release version: (build version) (tag version)
    echo "Released {{version}}"

# Sequential: b before a, c after a
a: b && c
    echo "A"
```

### Command Prefixes

| Prefix | Effect |
|--------|--------|
| `@` | Suppress echoing the command line |
| `-` | Continue on error (don't abort) |

```just
default:
    @just --list

clean:
    -rm -rf dist/
    -rm -rf build/
```

### Settings

```just
set shell := ["bash", "-euo", "pipefail", "-c"]
set dotenv-load                    # Load .env file
set dotenv-filename := ".env.local"  # Custom .env filename
set dotenv-path := "config/.env"   # Explicit .env path
set positional-arguments           # Enable $1, $2 syntax
set export                         # Export all variables as env vars
set quiet                          # Suppress command echoing globally
set fallback                       # Search parent dirs for justfile
set allow-duplicate-recipes        # Last definition wins
```

### Attributes

```just
[private]                          # Hide from --list
_helper:
    echo "Internal use only"

[no-cd]                            # Don't change to justfile directory
anywhere:
    pwd

[no-exit-message]                  # Suppress exit code message
may-fail:
    exit 1

[confirm("Are you sure?")]         # Require confirmation
dangerous:
    rm -rf ./data

[group: "database"]                # Group in --list output
db-migrate:
    alembic upgrade head

[working-directory: "frontend"]    # Run in specific directory
build-ui:
    npm run build

[unix]                             # Platform-specific
open:
    xdg-open .

[windows]
open:
    start .

[linux]
open:
    xdg-open .

[macos]
open:
    open .

[positional-arguments]             # Per-recipe positional args
run:
    echo $1 $2
```

### Conditionals

```just
val := if os() == "linux" { "apt" } else { "brew" }

greeting := if env("CI", "") != "" { "CI mode" } else { "local mode" }
```

Operators: `==`, `!=`, `=~` (regex match)

### Shebang Recipes

Each normal recipe line runs in a separate shell. Shebang recipes run the entire body as a single script:

```just
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing dependencies..."
    uv sync
    echo "Running migrations..."
    python manage.py migrate
    echo "Done!"

analyze:
    #!/usr/bin/env python3
    import json
    with open('data.json') as f:
        data = json.load(f)
    print(f"Found {len(data)} items")
```

### Modules and Imports

```just
# Declare submodules (searches foo.just, foo/mod.just, foo/justfile)
mod database
mod frontend 'ui/justfile'

# Import recipes from another file
import 'common.just'
import? 'optional.just'           # Optional (no error if missing)
```

Invoke submodule recipes: `just database::migrate` or `just database migrate`

### Export and Environment

```just
export DATABASE_URL := "postgres://localhost/mydb"

# Per-recipe export
test $PYTHONDONTWRITEBYTECODE="1":
    pytest

# Read environment
home := env("HOME")
port := env("PORT", "8080")
```

## Built-in Functions

```just
# System info
arch()                             # "x86_64", "aarch64", etc.
os()                               # "linux", "macos", "windows"
os_family()                        # "unix", "windows"
num_cpus()                         # Logical CPU count

# Environment
env('KEY')                         # Get or error
env('KEY', 'default')              # Get with fallback

# Path operations
parent_directory('a/b')            # "a"
file_name('a/b/foo.txt')           # "foo.txt"
file_stem('foo.txt')               # "foo"
extension('foo.tar.gz')            # "gz"
without_extension('f.txt')         # "f"
join('a', 'b', 'c')               # "a/b/c"
clean('a//b/../c')                 # "a/c"
absolute_path('rel')               # Full absolute path
path_exists('config.json')         # Boolean check

# Directories
justfile_directory()               # Dir containing justfile
invocation_directory()             # Where `just` was called from
source_directory()                 # Current source file's parent
home_directory()                   # User's home
cache_directory()                  # XDG cache dir
config_directory()                 # XDG config dir

# String operations
uppercase('hello')                 # "HELLO"
lowercase('HELLO')                 # "hello"
trim('  hi  ')                     # "hi"
replace('ab', 'a', 'x')           # "xb"
replace_regex('a1b2', '\d', 'X')   # "aXbX"
snakecase('fooBar')                # "foo_bar"
kebabcase('fooBar')                # "foo-bar"
quote("it's")                      # Shell-safe quoting

# Executable discovery
which('python3')                   # Find in PATH, empty if not found
require('python3')                 # Find in PATH, error if missing

# Hashing
sha256('content')                  # SHA-256 hash
sha256_file('path')                # SHA-256 of file
blake3('content')                  # BLAKE3 hash

# Other
uuid()                             # Random UUID v4
datetime('%Y-%m-%d')               # Formatted local time
datetime_utc('%Y-%m-%dT%H:%M:%S')  # Formatted UTC time
read('VERSION')                    # Read file contents
shell('echo hello')                # Execute and capture output
error('message')                   # Abort with error
semver_matches('1.2.3', '>=1.0')   # Check semver compatibility
```

## Common Patterns

### Default as Help

```just
default:
    @just --list
```

### Passthrough to Sub-Justfile

```just
rca-dev *ARGS:
    just --justfile rca-agent/justfile {{ARGS}}
```

### Module-Based Organization

```just
mod send
mod rca
mod web

dev:
    just web dev
```

### Dynamic Platform Dispatch

```just
install-deps:
    just _install-deps-{{os()}}

[private]
_install-deps-linux:
    sudo apt install build-essential

[private]
_install-deps-macos:
    brew install gcc
```

### Docker Integration

```just
set dotenv-load
project := env('COMPOSE_PROJECT_NAME', 'myapp')

up *args:
    docker compose up -d {{args}}

down:
    docker compose down

logs *services:
    docker compose logs -f {{services}}

exec service *cmd:
    docker compose exec {{service}} {{cmd}}
```

### Database Operations

```just
db-migrate:
    uv run alembic upgrade head

db-revision message:
    uv run alembic revision --autogenerate -m "{{message}}"

db-reset:
    uv run alembic downgrade base
    uv run alembic upgrade head
```

### Setup / Bootstrap

```just
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing dependencies..."
    uv sync
    cp -n .env.example .env || true
    echo "Done!"
```

## Agentic Optimizations

| Context | Command |
|---------|---------|
| List all recipes | `just --list` or `just -l` |
| Dry run (preview) | `just --dry-run recipe` |
| Show variables | `just --evaluate` |
| JSON recipe list | `just --dump --dump-format json` |
| Verbose execution | `just --verbose recipe` |
| Specific justfile | `just --justfile path recipe` |
| Working directory | `just --working-directory path recipe` |
| Choose interactively | `just --choose` |

## Troubleshooting

### Common Errors

**"Recipe line failed"** — each line runs in a separate shell:
```just
# Wrong: cd doesn't persist
wrong:
    cd subdir
    pwd            # Still in original directory!

# Fix: single line or shebang
right:
    cd subdir && pwd

right-alt:
    #!/usr/bin/env bash
    cd subdir
    pwd
```

**"Variable not found":**
```just
# Fix: define or use env() with default
var := env('VAR', 'default')
```

### Debugging

```bash
just --dry-run recipe              # Show without running
just --evaluate                    # Show all variables
just --dump                        # Show parsed justfile
just --verbose recipe              # Verbose execution
```

### Cross-Platform Tips

- Use `/` for paths (just handles separators)
- Add `justfile text eol=lf` to `.gitattributes`
- Set explicit shell: `set shell := ["bash", "-euo", "pipefail", "-c"]`
- Use shebang recipes for complex multi-line logic

## Best Practices

1. **Always provide `default` recipe** pointing to `just --list`
2. **Document every public recipe** with a comment line above it
3. **Use `@` prefix** to suppress command echo when appropriate
4. **Use shebang recipes** for multi-line logic (avoids separate-shell gotcha)
5. **Prefer `set dotenv-load`** for configuration
6. **Use modules** for large projects (>20 recipes)
7. **Include variadic `*args`** for passthrough flexibility
8. **Quote interpolated variables** in shell commands: `"{{var}}"`
9. **Mark helpers as `[private]`** or prefix with `_`
10. **Use `-` prefix** on cleanup commands that may fail
