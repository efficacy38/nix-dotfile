---
name: notebooklm
description: Use the installed NotebookLM CLI to create notebooks, add sources, research, ask questions, generate artifacts, and download results. Activates on explicit NotebookLM requests or requests to create NotebookLM podcasts, quizzes, flashcards, videos, reports, or study material.
---

# NotebookLM CLI

This repository packages `notebooklm-py`. Check `notebooklm --version` and command help before using flags not shown here.

## Preflight

```bash
notebooklm status
notebooklm list --json
```

If authentication has expired, diagnose with `notebooklm auth check` and run `notebooklm login`. Login opens a browser and must follow the environment's approval rules.

## Safety

- Read-only listing, status, and chat commands are safe to run when relevant.
- Creating a notebook, adding sources, researching, or generating an artifact changes the user's NotebookLM account; the user's request must authorize that workflow.
- Confirm the exact target before deleting notebooks, sources, artifacts, notes, or shares.
- Download only when the user requested a local artifact, and use an explicit non-existing or approved output path.
- Language configuration is account-wide. Change it only when the user requested that language or accepted the global effect; otherwise pass `--language` to the generation command.

## Context and concurrency

Prefer explicit full notebook IDs in automated workflows. Shared `notebooklm use` context can be overwritten by another process.

- Commands that accept `-n` use it for the notebook ID.
- Other commands use `--notebook` when supported.
- Use `notebooklm <group> <command> --help` to confirm the current interface.

## Core workflow

```bash
# Create and capture the returned ID
notebooklm create "Research topic" --json

# Add sources to the selected notebook
notebooklm source add "https://example.com/article" --notebook <notebook-id> --json
notebooklm source add "./paper.pdf" --notebook <notebook-id> --json

# Wait for indexing when later steps require ready sources
notebooklm source wait <source-id> -n <notebook-id> --json

# Ask questions without relying on global context
notebooklm ask "Summarize the evidence" --notebook <notebook-id> --json

# Generate and monitor an artifact
notebooklm generate audio "Focus on the main findings" --notebook <notebook-id> --json
notebooklm artifact wait <artifact-id> -n <notebook-id> --timeout 1200 --json

# Download the completed artifact
notebooklm download audio "./podcast.mp3" -n <notebook-id> -a <artifact-id>
```

Confirm exact flags against the installed 0.3.2 CLI before execution; subcommands do not all use the same notebook option.

## Research

```bash
# Fast research
notebooklm source add-research "query" --mode fast --notebook <notebook-id>

# Start deep research without blocking
notebooklm source add-research "query" --mode deep --no-wait --notebook <notebook-id>

# Import completed results
notebooklm research wait -n <notebook-id> --import-all --timeout 1800
```

Use the product's recurring wait mechanism for long operations. Do not create a subagent merely to sleep or poll.

## Artifact commands

Discover current types and options with:

```bash
notebooklm generate --help
notebooklm download --help
notebooklm artifact list --help
```

Common generation types include audio, video, slide decks, infographics, reports, mind maps, data tables, quizzes, and flashcards. Generation can be rate-limited and may take several minutes. Return task or artifact IDs in progress updates, and distinguish timeout from generation failure.

## Failure handling

- Authentication failure: `notebooklm auth check`, then re-authenticate if required.
- Missing context: pass an explicit notebook ID instead of relying on `notebooklm use`.
- Source still processing: wait for that source before chat or generation.
- Rate limit or generation failure: report the server state and retry only within the user's request.
- Unknown flag or status: inspect the installed command's `--help`; do not rely on remembered interfaces.
