# Python Standards

Language-specific standards for Python development using uv, ruff, pyright, and pytest. Referenced from the main `coding-standards` skill.

## Running Python Commands

**Always use `uv run` to execute Python tools:**

```bash
uv run python3 -m <module_name> <args>
uv run pytest tests/ -v
uv run ruff format <path>/
uv run ruff check --fix <path>/
uv run ruff format --check <path>/
uv run ruff check <path>/
uv run pyright <path>/
```

**Note:** If a project doesn't have `tool.uv.package = true` in pyproject.toml, entry points won't work. Use `python3 -m <module>` instead.

## Code Style Checks

```bash
# Use justfile recipes (preferred):
just fmt     # Auto-fix: ruff format + ruff check --fix
just lint    # Read-only: ruff format --check + ruff check + pyright
just test    # Run tests

# Or run manually:
uv run ruff format .           # Format code
uv run ruff check --fix .      # Fix lint issues (includes import sorting via "I" rules)
uv run pyright <package>/      # Type check
uv run pytest tests/ -v        # Run tests
```

## Justfile Convention

| Recipe | Purpose | Mode | Command pattern |
|---|---|---|---|
| `fmt` | Auto-fix formatting + lint | Write | `ruff format . && ruff check --fix .` |
| `lint` | Read-only check (CI-safe) | Read-only | `ruff format --check . && ruff check . && pyright <pkg>/` |
| `test` | Run tests | Read-only | `pytest tests/ -v` |

**Always prefer `just fmt`/`just lint`/`just test` over running tools directly.**

## Common Linter Fixes

| Error | Fix |
|-------|-----|
| `F401 imported but unused` | Remove the unused import |
| `F841 local variable assigned but never used` | Remove assignment or use `_` prefix |
| Import order issues | Run `ruff check --fix .` (ruff "I" rules handle import sorting) |

## Testing

### Tooling

**Use:** `pytest`, `pytest-cov`, `pytest-asyncio`, `pytest-mock`, `respx`/`pytest-httpx` (HTTP mocking for httpx)

**Avoid:** `unittest` style (use pytest native), `nose` (deprecated), standalone `mock` (use pytest-mock)

```bash
uv add --dev pytest pytest-cov pytest-asyncio pytest-mock
```

### pyproject.toml Configuration

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"
addopts = ["-ra", "-q", "--strict-markers", "--strict-config"]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
]

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
exclude_lines = ["pragma: no cover", "if TYPE_CHECKING:", "raise NotImplementedError"]
```

### Directory Structure

```
tests/
├── conftest.py          # Shared fixtures
├── unit/
│   └── test_service.py
└── integration/
    └── test_api.py
```

### Writing Tests

**Imports at top level, not inside functions:**

```python
# CORRECT
import pytest
from unittest.mock import MagicMock, patch
from mymodule import MyClass, my_function

class TestMyClass:
    def test_something(self):
        pass
```

### Parametrized Tests

```python
@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add(a, b, expected):
    assert add(a, b) == expected
```

### Fixtures

```python
# tests/conftest.py
@pytest.fixture
def sample_user():
    return {"id": 1, "name": "Test User", "email": "test@example.com"}

@pytest.fixture
def db():
    """Setup/teardown fixture."""
    database = Database(":memory:")
    database.connect()
    yield database
    database.disconnect()

@pytest.fixture(scope="module")
def expensive_resource():
    """Shared across module (use sparingly)."""
    resource = create_expensive_resource()
    yield resource
    resource.cleanup()
```

### Exception Testing

```python
def test_invalid_email_raises():
    with pytest.raises(ValueError) as exc_info:
        validate_email("not-an-email")
    assert "Invalid email format" in str(exc_info.value)
```

### Markers

```python
@pytest.mark.slow
def test_complex_calculation():
    """Run with: pytest -m slow"""
    pass

@pytest.mark.integration
async def test_database_connection():
    """Run with: pytest -m integration"""
    pass

@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass
```

### Mocking Patterns

**Use context manager style for multiple patches:**

```python
# Modern Python 3.10+ style with parentheses
with (
    patch("module.function1") as mock1,
    patch("module.function2") as mock2,
):
    mock1.return_value = "value"
```

**Patch where the function is used, not where it's defined:**

```python
# If tools.py imports: from mymodule import my_function
# Patch at the usage location:
with patch("package.tools.my_function") as mock:
    pass

# NOT at the definition location:
with patch("mymodule.my_function") as mock:  # Won't work!
    pass
```

**Mock async functions with `AsyncMock`:**

```python
from unittest.mock import AsyncMock

async def test_external_api(mocker):
    mock_fetch = mocker.patch(
        "mypackage.client.fetch_data",
        new_callable=AsyncMock,
        return_value={"data": "mocked"}
    )
    result = await process_data()
    assert result["data"] == "mocked"
    mock_fetch.assert_awaited_once()
```

**HTTP mocking with respx (for httpx):**

```python
import respx

@respx.mock
async def test_api_call():
    respx.get("https://api.example.com/users/1").respond(
        json={"id": 1, "name": "John"}
    )
    async with httpx.AsyncClient() as client:
        response = await client.get("https://api.example.com/users/1")
    assert response.json()["name"] == "John"
```

### Patching Lazy Imports in Tests

When a module uses lazy/local imports inside functions, the standard "patch where used" rule inverts:

```python
# Source module (rca_agent/llm.py):
def extract_search_criteria_with_llm(text):
    ...

# Consumer module (rca_agent/web/routers/sessions.py):
def some_endpoint():
    from rca_agent.llm import extract_search_criteria_with_llm  # lazy import
    result = extract_search_criteria_with_llm(text)
```

**Patch at the source module, not the consumer:**

```python
# CORRECT — patches the source before lazy import pulls it
with patch("rca_agent.llm.extract_search_criteria_with_llm"):
    ...

# WRONG — lazy import hasn't created this attribute yet
with patch("rca_agent.web.routers.sessions.extract_search_criteria_with_llm"):
    ...
```

**Why:** Top-level `from X import Y` copies the reference into the consumer's namespace (so you patch the consumer). Lazy imports inside functions fetch from the source each time (so you patch the source).

### Running Tests

```bash
pytest                                        # All tests
pytest --cov --cov-report=term-missing        # With coverage
pytest tests/unit/test_service.py             # Specific file
pytest tests/unit/test_service.py::test_func  # Specific test
pytest -m "not slow"                          # By marker
pytest -x                                     # Stop on first failure
pytest --lf                                   # Run last failed
pytest -n auto                                # Parallel (pytest-xdist)
pytest --cov=src --cov-fail-under=80          # Fail below threshold
```

### Testing Best Practices

**DO:** Descriptive test names (`test_<what>_<condition>_<expected>`), fixtures for setup/teardown, test edge cases and error paths, mock external services.

**DON'T:** Test implementation details, use `time.sleep()` in tests, share state between tests, test private methods directly, write order-dependent tests.

## Async Patterns

**Never block the event loop:**

```python
# WRONG
import time
time.sleep(5)

# CORRECT
import asyncio
await asyncio.sleep(5)
```

**Wrap blocking I/O calls with `asyncio.to_thread`:**

```python
# WRONG — blocking SDK call in async context
run = client.read_run(str(run_id))

# CORRECT — offload to thread pool
run = await asyncio.to_thread(client.read_run, str(run_id))
```

Quick pure computation doesn't need wrapping — only I/O-bound blocking calls.

## Async Test Pattern

```python
import pytest

class TestAsyncFeature:
    @pytest.mark.asyncio
    async def test_async_function(self):
        result = await my_async_function()
        assert result == expected
```

## Package Management with uv

**Use `uv` exclusively. Never use `pip`, `pip-tools`, or `poetry` directly.**

```bash
uv add <package>          # Add runtime dependency
uv add --dev <package>    # Add dev dependency
uv remove <package>       # Remove dependency
uv sync                   # Sync from lock file
uv run script.py          # Run script with proper deps
```

### Inline Script Metadata

Scripts can declare their own dependencies without a project:

```python
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "requests",
#     "pandas",
# ]
# ///

import requests
import pandas as pd
```

Manage script-level deps:

```bash
uv add package-name --script script.py
uv remove package-name --script script.py
uv sync --script script.py
```

## Import Practices

**Declared dependencies get unconditional imports — no guards:**

```python
# CORRECT — dependency is in pyproject.toml
from rspamd_query import RspamdClient

# WRONG — unnecessary guard for a declared dependency
try:
    from rspamd_query import RspamdClient
    RSPAMD_AVAILABLE = True
except ImportError:
    RSPAMD_AVAILABLE = False
```

**Exceptions:**
- Diagnostic scripts whose purpose is to test whether imports work
- Lazy imports inside functions for heavy modules only needed in rare code paths

## TypedDict vs Pydantic BaseModel

**Use TypedDict** for lightweight type hints on plain dicts — no runtime overhead, no validation.

**Use Pydantic BaseModel** when you need constructors with defaults, validation, or framework integration.

**Migration patterns (TypedDict -> BaseModel):**

| TypedDict pattern | BaseModel pattern |
|---|---|
| `state["field"]` | `state.field` |
| `state.get("field", default)` | `state.field` (defaults on model) |
| `{**state, "key": val}` | `state.model_copy(update={"key": val})` |
| `dict(state)` / dict literal | `state.model_dump()` |

**Common pitfalls:**
- `{**state, ...}` does NOT work on Pydantic models — use `model_copy(update=...)`
- Mutable defaults must use `Field(default_factory=...)`
- When an API expects a dict, call `model_dump()`

## Click CLI Best Practices

**Let Click handle what Click handles:**

```python
# CORRECT — Click enforces required arguments automatically
@cli.command()
@click.argument("goal")
def agent(goal: str) -> None:
    ...
```

**Use `cli.commands` instead of hardcoded command sets.**

**Use `Path.write_text()` / `Path.write_bytes()` for one-shot writes.**

## MCP Server Pattern

```bash
# Run with stdio transport
uv run python3 -m <package> mcp --config <path>
```

## Debugging Tips

1. **Module not found errors**: Use `python3 -m <module>` instead of entry point
2. **Import errors in tests**: Check patch paths match where function is imported
3. **Async test issues**: Ensure `pytest-asyncio` is installed and use `@pytest.mark.asyncio`
