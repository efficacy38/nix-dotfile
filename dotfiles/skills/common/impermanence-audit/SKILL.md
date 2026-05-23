---
name: impermanence-audit
description: Audit NixOS impermanence configuration — find files on root filesystem not covered by persistence declarations. Use when the user wants to check for untracked files, audit impermanence, or runs /impermanence-audit.
allowed-tools: Bash(sudo:*), Bash(bash:*), Bash(nix:*), Read, Edit, Glob, Grep
---

# Impermanence Audit

Scan the root filesystem and identify files not covered by NixOS impermanence persistence declarations. These files would be lost on reboot.

## Workflow

### 1. Run the audit script

```bash
sudo impermanence-audit --hostname stella
```

Options:
- `--hostname NAME` — NixOS host config to evaluate (default: `$(hostname)`)
- `--user NAME` — user home to check (default: current user)
- `--ignore FILE` — extra ignore patterns file
- `--json` — machine-readable output

### 2. Analyze results

Review the untracked files and categorize them:

| Category | Action |
|----------|--------|
| **Application state/config** | Add to the appropriate feature module's `environment.persistence` |
| **Transient/cache files** | Safe to ignore — add to `~/.config/impermanence-audit/ignore` if noisy |
| **System service data** | Add to the system module (usually `features/system/boot.nix`) |
| **Unknown** | Investigate what created the file before deciding |

### 3. Add missing persistence declarations

Persistence paths are declared across feature modules. Match the file to its feature:

| Path pattern | Module file |
|---|---|
| Desktop app configs (`~/.config/app`, `~/.local/share/app`) | `flake-modules/modules/features/desktop/common.nix` |
| Dev tools (`~/.kube`, `.local/share/direnv`, etc.) | `flake-modules/modules/features/devpack/tools.nix` |
| Editor data (`~/.local/share/nvim`) | `flake-modules/modules/features/devpack/editor.nix` |
| System services (`/var/lib/*`, `/etc/*`) | `flake-modules/modules/features/system/boot.nix` |
| KDE state | `flake-modules/modules/features/desktop/kde.nix` |
| Steam/gaming | `flake-modules/modules/features/desktop/steam.nix` |
| Browser profiles | `flake-modules/modules/features/desktop/zen.nix` |

The pattern for adding a user directory to a feature module:

```nix
# Inside the module's config block, guarded by impermanence check:
config = lib.mkIf (cfg.enable && config.my.system.impermanence.enable) {
  environment.persistence."/persistent/system".users."efficacy38" = {
    directories = [
      ".config/new-app"
      ".local/share/new-app"
    ];
  };
};
```

For system-level paths:

```nix
environment.persistence."/persistent/system" = {
  directories = [
    "/var/lib/new-service"
  ];
};
```

### 4. Rebuild and verify

After adding persistence declarations:

```bash
nh os switch --hostname=stella
```

Then re-run the audit to confirm the paths are now covered.
