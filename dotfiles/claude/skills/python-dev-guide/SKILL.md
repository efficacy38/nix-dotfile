---
name: python-dev-guide
description: python development guide, you MUST use this skill when developing a python project
---

# Python Development Guide

## Overview

This skill provides patterns for Python development using uv package manager and pytest testing in projects with Nix flakes.

## Running Python Commands

**Always use `uv run` to execute Python tools:**

```bash
# Run a module
uv run python3 -m <module_name> <args>

# Run pytest
uv run pytest tests/ -v

# Run formatters
uv run black <path>/
uv run isort <path>/

# Run linters
uv run flake8 <path>/
uv run pyright <path>/
```

**Note:** If a project doesn't have `tool.uv.package = true` in pyproject.toml, entry points won't work. Use `python3 -m <module>` instead of the entry point command.

## Code Style Checks

Run these in order:

```bash
# 1. Format code
uv run black <path>/
uv run isort <path>/

# 2. Lint
uv run flake8 <path>/

# 3. Type check
uv run pyright <path>/

# 4. Run tests
uv run pytest tests/ -v
```

## Common Linter Fixes

| Error | Fix |
|-------|-----|
| `F401 imported but unused` | Remove the unused import |
| `F841 local variable assigned but never used` | Remove assignment or use `_` prefix |
| Import order issues | Run `isort` to fix automatically |

## Test Structure

```
tests/
├── __init__.py
├── <module>/
│   ├── __init__.py
│   ├── test_<feature>.py
│   └── test_<other>.py
```

## Writing Tests

**Imports at top level, not inside functions:**

```python
# CORRECT - imports at module level
import pytest
from unittest.mock import MagicMock, patch

from mymodule import MyClass, my_function

class TestMyClass:
    def test_something(self):
        # test code here
        pass
```

```python
# WRONG - imports inside functions
class TestMyClass:
    def test_something(self):
        from mymodule import MyClass  # Don't do this!
        pass
```

## Mocking Patterns

**Use context manager style for multiple patches:**

```python
# Modern Python 3.10+ style with parentheses
with (
    patch("module.function1") as mock1,
    patch("module.function2") as mock2,
):
    mock1.return_value = "value"
    # test code
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

## Async Test Pattern

```python
import pytest

class TestAsyncFeature:
    @pytest.mark.asyncio
    async def test_async_function(self):
        result = await my_async_function()
        assert result == expected
```

## Adding Dependencies

```bash
# Add runtime dependency
uv add <package>

# Add dev dependency
uv add --dev <package>

# Sync dependencies
uv sync
```

## MCP Server Pattern

For MCP servers using FastMCP:

```bash
# Run with stdio transport (for Claude Code)
uv run python3 -m <package> mcp --config <path>

# Test with JSON-RPC via stdio
printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}\n{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | uv run python3 -m <package> mcp --config <path>
```

## Debugging Tips

1. **Module not found errors**: Use `python3 -m <module>` instead of entry point
2. **Import errors in tests**: Check patch paths match where function is imported
3. **Async test issues**: Ensure `pytest-asyncio` is installed and use `@pytest.mark.asyncio`
