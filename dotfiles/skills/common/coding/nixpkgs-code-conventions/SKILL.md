---
name: nixpkgs-code-conventions
description: Use when contributing to NixOS/nixpkgs - writing packages, NixOS modules, lib functions, or committing changes. Covers naming, syntax, formatting, and commit message conventions.
---

# Nixpkgs Code Conventions

Before editing, read the current repository-level `CONTRIBUTING.md` and the nearest area-specific README. Those files take precedence over this summary because nixpkgs policy changes.

## Stable defaults

- Keep each commit to one logical change.
- Use lowercase kebab-case for Nix files and directories.
- Use `lowerCamelCase` for local Nix variables.
- Preserve upstream package names where nixpkgs naming rules permit them.
- List function arguments explicitly; use `...` only when the function intentionally accepts additional attributes.
- Avoid redundant interpolation such as `"${version}"` when `version` is already a string.
- Use `lib.optional` and `lib.optionals` for conditional list members.
- Do not request changes for style choices that the applicable documentation leaves to author discretion.

## Verification

Use the commands documented by the current nixpkgs checkout. At minimum, format the changed Nix files, evaluate the affected attribute or module, and run the narrowest relevant test. Do not substitute a local convention for an explicit nixpkgs rule.

## Commit messages

Confirm the current contribution guide before committing. Common forms are:

- package update: `package-name: old-version -> new-version`
- new package: `package-name: init at version`
- NixOS module: `nixos/module: description`
- library change: `lib.area: description`

Explain the reason for non-trivial changes in the body and link upstream release notes for version updates.
