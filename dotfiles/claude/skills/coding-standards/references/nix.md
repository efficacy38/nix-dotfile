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

## NixOS VM Test Pitfalls

When writing NixOS integration tests (`nixos/tests/`), keep these constraints in mind:

| Pitfall | Explanation | Fix |
|---------|-------------|-----|
| Writing to `/etc` | `/etc` is read-only in NixOS VMs (managed by activation scripts) | Write to `/root/.ssh/`, `/tmp/`, or `/run/` instead |
| Service filesystem access | Services with `ProtectSystem=strict` (e.g., nginx) can't write to arbitrary paths | Add `systemd.services.<name>.serviceConfig.ReadWritePaths` |
| Unreachable network services | The default NixOS firewall blocks all ports not explicitly opened | Add ports to `networking.firewall.allowedTCPPorts` |
| Shared backend storage | Multiple test configs pointing to the same storage URL share a repository | Use distinct sub-paths per test config |

## Indented String Dollar Escaping

In Nix indented strings (`'' ''`), `$` followed by `{` triggers interpolation just like in regular strings. To produce a literal `$` followed by a Nix-interpolated value (e.g. a shell variable reference like `$REPO_ARGS`), use the `''$` escape sequence followed by the interpolation:

```nix
# GOOD — ''$ escapes the dollar, then ${...} interpolates normally
mkConnectOrCreate = kopiaExe: backendType: argsVar:
  ''
    ${kopiaExe} repository connect ${backendType} ''$${argsVar}
  '';
# With argsVar = "REPO_ARGS", produces: kopia repository connect s3 $REPO_ARGS

# BAD — bare $$ does NOT escape $ in indented strings
''
  kopia connect $${argsVar}
''
# Produces: kopia connect ${argsVar}  (literal text, not interpolated)
```

Key rules for `$` in indented strings:
- `''$` produces a literal `$` (the indented-string escape)
- `''${` produces a literal `${` (escapes interpolation)
- `''$${expr}` produces a literal `$` followed by the interpolated value of `expr`
- `$$` is **not** an escape — it produces literal `$$` text

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
