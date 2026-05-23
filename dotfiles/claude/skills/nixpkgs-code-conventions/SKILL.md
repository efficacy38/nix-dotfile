---
name: nixpkgs-code-conventions
description: Use when contributing to NixOS/nixpkgs - writing packages, NixOS modules, lib functions, or committing changes. Covers naming, syntax, formatting, and commit message conventions.
---

# Nixpkgs Code Conventions

## Overview

Official code conventions for contributing to [NixOS/nixpkgs](https://github.com/NixOS/nixpkgs). Source: CONTRIBUTING.md and area-specific READMEs.

## When to Use

- Writing or modifying Nix expressions in nixpkgs
- Creating commit messages for nixpkgs PRs
- Naming packages, files, or directories
- Reviewing nixpkgs contributions

## File Naming

- **Kebab case only**: `all-packages.nix`, NOT `allPackages.nix` or `AllPackages.nix`
- Lowercase, dashes between words

## Formatting

CI enforces formatting via [nixfmt](https://github.com/NixOS/nixfmt). Run before committing:

```bash
nix-shell --run treefmt
# or
nix develop --command treefmt
# or
nix fmt
```

## Syntax Rules

### Variable Naming

- `lowerCamelCase` for variables (NOT `UpperCamelCase`)
- Package attribute names follow separate rules (see Package Naming below)

### Function Arguments

List arguments explicitly:

```nix
# GOOD
{ stdenv, fetchurl, perl }:
```

```nix
# BAD - too vague
args: with args;

# BAD - unnecessary ellipsis
{ stdenv, fetchurl, perl, ... }:
```

For truly generic functions, use `@`-pattern:

```nix
{ stdenv, doCoverageAnalysis ? false, ... }@args:
stdenv.mkDerivation (args // { foo = if doCoverageAnalysis then "bla" else ""; })
```

### Avoid Unnecessary String Conversions

```nix
# GOOD
{ tag = version; }

# BAD
{ tag = "${version}"; }
```

### Conditional Lists

Use `lib.optional(s)` instead of if-else:

```nix
# GOOD
{ buildInputs = lib.optional stdenv.hostPlatform.isDarwin iconv; }

# BAD
{ buildInputs = if stdenv.hostPlatform.isDarwin then [ iconv ] else null; }
```

Exception: explicit `if/else null` is acceptable to avoid mass rebuilds, with a follow-up PR to convert.

### Style Discretion

Unlisted style choices are at author discretion. Do not comment on them in reviews to avoid churn.

## Package Naming

| Name Type | Rules |
|-----------|-------|
| `pname` | Identical to upstream name; **no uppercase** (e.g., `"mplayer"` not `"MPlayer"`) |
| Attribute name | Must be valid Nix identifier; prefix with `_` if starts with digit (e.g., `_0ad`); use same as `pname`; keep hyphens (no snake/camel conversion) |
| File/directory | Kebab case, lowercase |

Multiple versions: `json-c_0_9`, `json-c_0_11`, with default alias `json-c = json-c_0_9;`

## Commit Conventions

### General Rules

- One commit per logical unit
- Squash fix-up commits (`git rebase -i`)
- **No period** at end of summary line
- Adding to `maintainer-list.nix`: separate commit with `maintainers: add <handle>`, placed before package changes

### Commit Message Formats by Area

| Area | Format | Example |
|------|--------|---------|
| **pkgs** | `pkg-name: from -> to` | `firefox: 54.0.1 -> 55.0` |
| **pkgs** (new) | `pkg-name: init at version` | `nginx: init at 2.0.1` |
| **nixos** | `nixos/module: description` | `nixos/hydra: add bazBaz option` |
| **lib** | `lib.section: description` | `lib.fileset: add additional argument` |

The `pkg-name:` prefix triggers automatic CI builds. Supported patterns:

```
vim: 1.0.0 -> 2.0.0                              # builds vim
python3{9,10}Packages.requests: 1.0.0 -> 2.0.0   # builds both
python312.pkgs.numpy,python313.pkgs.scipy: fix    # builds both
```

### Commit Message Body

- Explain *why* the change was made
- Include link to release notes/changelog for version updates
- More extensive changes require more verbose messages

## PR Conventions

- PR title prefixed with `WIP:` or containing `[WIP]` prevents automatic CI builds
- Draft PRs still trigger automatic builds
- Keep PR title in sync with commit title
- Apply all relevant labels and tick relevant checkboxes
- Non-blocking comments are default; blocking must use GitHub "Request Changes"

## Release Notes

If removing packages or making major NixOS changes, document in `nixos/doc/manual/release-notes`.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `UpperCamelCase` for variables | Use `lowerCamelCase` |
| `if cond then [x] else []` | Use `lib.optional cond x` |
| `{ tag = "${version}"; }` | Use `{ tag = version; }` |
| `args: with args;` | List arguments explicitly |
| Period at end of commit summary | Remove the period |
| CamelCase filenames | Use kebab-case |
| Uppercase in `pname` | Use lowercase only |
| Missing commit prefix | Use `pkg-name:` or `nixos/module:` format |
