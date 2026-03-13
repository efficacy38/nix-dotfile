---
name: sqlalchemy-schema-migration-gotcha
description: Use when adding columns to existing SQLAlchemy/SQLModel models, troubleshooting
  schema drift, or setting up Alembic with async engines and externally-managed tables
---

# SQLAlchemy Schema Migration Gotcha

## The Problem

`Base.metadata.create_all(engine)` only creates **new tables**. It does NOT add new columns to existing tables.

Adding a new field to a SQLAlchemy model and restarting the app will cause runtime errors:

```
sqlalchemy.exc.ProgrammingError: column "auto_select" of relation "sessions" does not exist
```

## Why It Happens

`create_all()` checks if a table exists by name. If the table already exists, it skips it entirely — even if the model has new columns that the table lacks.

## Solution: Alembic Migrations

This project uses Alembic for proper schema migrations (set up in `rca-agent/`):

```bash
# Generate migration after model changes
just db-revision "add auto_select to sessions"

# Apply migrations
just db-upgrade

# Rollback one step
just db-downgrade

# View history
just db-history
```

## Async Engine Setup

When using Alembic with `asyncpg`/`psycopg` async engines, `env.py` must use `async_engine_from_config` and `connection.run_sync()`:

```python
async def run_async_migrations() -> None:
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()
```

## Excluding Externally-Managed Tables

When other systems (e.g. LangGraph checkpointer) create tables in the same database, use `include_name` to prevent Alembic autogenerate from dropping them:

```python
EXCLUDED_TABLES = {"checkpoint_blobs", "checkpoint_migrations", ...}

def include_name(name, type_, parent_names):
    return not (type_ == "table" and name in EXCLUDED_TABLES)

# Pass to context.configure()
context.configure(connection=connection, target_metadata=metadata, include_name=include_name)
```

## Running Migrations on App Startup

Use `asyncio.to_thread` to run Alembic's synchronous `upgrade` from an async context:

```python
alembic_cfg = AlembicConfig(str(Path(__file__).resolve().parents[3] / "alembic.ini"))
await asyncio.to_thread(command.upgrade, alembic_cfg, "head")
```

## Key Takeaway

When you add a column to an existing SQLAlchemy/SQLModel model:
1. Run `just db-revision "description"` to generate a migration
2. Run `just db-upgrade` to apply it
3. **Never assume** `create_all()` will update existing tables
