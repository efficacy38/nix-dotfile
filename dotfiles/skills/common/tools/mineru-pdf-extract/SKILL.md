---
name: mineru-pdf-extract
description: Use when extracting PDFs, scans, images, Office documents, URLs, or web pages with MinerU, especially for OCR, tables, formulas, Markdown, HTML, LaTeX, DOCX, or JSON output.
---

# MinerU document extraction

Use the installed `mineru-open-api` CLI. Treat its `--help` output as the source of truth because formats and limits can change between versions.

## Choose a mode

| Need | Command |
|---|---|
| Quick Markdown, no token, file within the advertised flash limits | `flash-extract` |
| OCR or precise layout and assets | `extract` |
| HTML, LaTeX, DOCX, JSON, batch input, or larger documents | `extract` |
| Web page content | `crawl` |

Current flash extraction advertises a 10 MB and 20-page limit. Confirm with `mineru-open-api flash-extract --help` before relying on it.

## Workflow

1. Inspect the requested input and output format.
2. Check the relevant command help.
3. Start with flash extraction only when its limits and Markdown output satisfy the request.
4. Use authenticated extraction for other formats, batch jobs, or higher-fidelity output.
5. Inspect the produced Markdown and assets for missing pages, broken tables, formula errors, or OCR corruption.

```bash
# Fast Markdown to stdout
mineru-open-api flash-extract "report.pdf"

# Fast extraction to a directory
mineru-open-api flash-extract "report.pdf" -o "./report-output"

# Authenticated multi-format extraction
mineru-open-api extract "report.pdf" -o "./report-output" -f md,docx

# OCR or selected pages
mineru-open-api extract "scan.pdf" --ocr --pages 1-10 -o "./scan-output"

# Web page extraction
mineru-open-api crawl "https://example.com/article" -o "./article-output"
```

Run `mineru-open-api auth` before `extract` or `crawl` when no token is configured. Do not print, persist, or expose the token in task output.

## Output rules

- Quote input and output paths.
- Omit `-o` only when stdout is the intended result.
- Use an explicit output directory for batch jobs, binary formats, and extracted assets.
- Do not overwrite an existing user directory without confirming the target.
- Report the resulting path and any extraction defects; do not claim OCR or table accuracy without inspection.

## Failure handling

- Limit error: switch from `flash-extract` to authenticated `extract`.
- Authentication error: run `mineru-open-api auth` or verify the configured token source.
- Layout or hallucination concern: compare available models using current help and inspect against the source pages.
- Unsupported flag or format: use `mineru-open-api <command> --help`; do not guess from this skill.
