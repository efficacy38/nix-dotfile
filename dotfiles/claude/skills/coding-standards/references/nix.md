# Nix / Nixpkgs Code Conventions

Language-specific standards for Nix expressions and nixpkgs contributions. Referenced from the main `coding-standards` skill.

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

## Package Naming

| Name Type | Rules |
|-----------|-------|
| `pname` | Identical to upstream name; **no uppercase** (e.g., `"mplayer"` not `"MPlayer"`) |
| Attribute name | Must be valid Nix identifier; prefix with `_` if starts with digit (e.g., `_0ad`); keep hyphens |
| File/directory | Kebab case, lowercase |

Multiple versions: `json-c_0_9`, `json-c_0_11`, with default alias `json-c = json-c_0_9;`

## Commit Conventions (nixpkgs)

### General Rules

- One commit per logical unit
- Squash fix-up commits (`git rebase -i`)
- **No period** at end of summary line

### Commit Message Formats by Area

| Area | Format | Example |
|------|--------|---------|
| **pkgs** | `pkg-name: from -> to` | `firefox: 54.0.1 -> 55.0` |
| **pkgs** (new) | `pkg-name: init at version` | `nginx: init at 2.0.1` |
| **nixos** | `nixos/module: description` | `nixos/hydra: add bazBaz option` |
| **lib** | `lib.section: description` | `lib.fileset: add additional argument` |

The `pkg-name:` prefix triggers automatic CI builds. Body should explain *why* and link to release notes for version updates.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `UpperCamelCase` for variables | Use `lowerCamelCase` |
| `if cond then [x] else []` | Use `lib.optional cond x` |
| `{ tag = "${version}"; }` | Use `{ tag = version; }` |
| `args: with args;` | List arguments explicitly |
| Period at end of commit summary | Remove the period |
| CamelCase filenames | Use kebab-case |
| Uppercase in `pname` | Use lowercase only |
| Missing commit prefix | Use `pkg-name:` or `nixos/module:` format |
