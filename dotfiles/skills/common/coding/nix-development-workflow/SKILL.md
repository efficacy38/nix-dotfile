---
name: nix-development-workflow
description: Use when developing, testing, formatting, or building a repository that contains flake.nix, or when changing Nix and NixOS configuration.
---

# Nix development workflow

Use the repository's flake as the development environment and source of tooling.

## Command routing

When `flake.nix` exists in the repository or a parent directory:

- Run development tools inside the appropriate shell: `nix develop -c <command> <args>`.
- Select a named shell when the flake defines one, for example `nix develop .#backend -c pytest`.
- Run Nix management commands directly. Do not wrap `nix build`, `nix develop`, `nix flake check`, `nix fmt`, or `nh os switch` inside another development shell.
- Prefer commands already defined by the repository, such as `just`, package scripts, or flake checks, over ad hoc replacements.

If the required tool is not provided by the flake, use `nix shell nixpkgs#<package> -c <command>` for a one-off check. Add a dependency to the flake only when it is part of the project's reproducible development environment.

## Verification

Use the smallest relevant sequence:

1. Run the formatter in check mode when available.
2. Run the targeted type, lint, or test command for the changed area.
3. Run `nix flake check --no-build` for flake or module changes.
4. Run the required build only when evaluation is insufficient.

Report unrelated pre-existing failures separately from failures introduced by the change.
