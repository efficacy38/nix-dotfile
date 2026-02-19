---
name: sqlalchemy-schema-migration-gotcha
description: Use when adding columns to existing SQLAlchemy models or troubleshooting
  "column does not exist" errors after model changes
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

## Quick Fix (Development)

Run an `ALTER TABLE` to add the column manually:

```sql
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS auto_select BOOLEAN NOT NULL DEFAULT false;
```

Or drop and recreate the table (if data loss is acceptable):

```sql
DROP TABLE IF EXISTS sessions CASCADE;
-- Then restart the app so create_all() recreates it
```

## Production Fix

Use **Alembic** for proper schema migrations:

```bash
# Generate migration
alembic revision --autogenerate -m "add auto_select to sessions"

# Apply migration
alembic upgrade head
```

## Key Takeaway

When you add a column to an existing SQLAlchemy model:
1. **Dev:** manually `ALTER TABLE` or drop+recreate
2. **Production:** always use Alembic migrations
3. **Never assume** `create_all()` will update existing tables
