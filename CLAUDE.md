# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

### System Management
```bash
# Switch to a NixOS configuration (standard method)
nh os switch --hostname=<hostname>

# Switch from minimal environment (bootstrap)
nix shell nixpkgs#nh
nh os switch --hostname=phoenixton

# Build without switching
nh os build --hostname=<hostname>

# Check flake for errors
nix flake check
```

### Formatting
```bash
# Format all Nix files (uses nixfmt-tree)
nix fmt
```

### ISO Building
```bash
# Build minimal installation ISO
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```

## Architecture Overview

### Flake-Parts + Dendritic Pattern

This repository uses **flake-parts** with a **dendritic pattern** for modular configuration:

1. **Main entry**: `flake.nix` imports flake-parts and delegates to modules in `flake-modules/`
2. **Module auto-loading**: Uses `import-tree` (from vic/import-tree) to automatically import all `.nix` files under `flake-modules/modules/`
3. **Module aggregation**:
   - `flake-modules/nixos-modules.nix` merges all `nixosModules` into `flake.nixosModules.default`
   - `flake-modules/home-modules.nix` merges all `homeModules` into `flake.homeModules.default`

### Module Organization

Modules follow a **features and bundles** pattern under `flake-modules/modules/`:

**Features** (granular functionality):
- `features/system/` - System-level configs (boot, network, virtualization, backup, etc.)
- `features/desktop/` - Desktop environment features (hyprland, kde, steam, laptop, etc.)
- `features/devpack/` - Development tools (editor, shell, tools, work)

**Bundles** (pre-configured sets of features):
- `bundles/common.nix` - Base configuration for all systems
- `bundles/desktop-hyprland.nix` - Complete Hyprland desktop setup
- `bundles/desktop-kde.nix` - Complete KDE desktop setup
- `bundles/server.nix` - Server configuration
- `bundles/homelab.nix` - Homelab-specific setup
- `bundles/minimal.nix` - Minimal system
- `bundles/steam.nix` - Gaming setup

### Module Pattern

Each module file exports either `flake.nixosModules.<name>` or `flake.homeModules.<name>`:

```nix
# Example structure
{ ... }:
{
  flake.nixosModules.feature-name = { config, lib, ... }: {
    options.my.feature-name = {
      enable = lib.mkEnableOption "description";
    };

    config = lib.mkIf config.my.feature-name.enable {
      # Configuration here
    };
  };
}
```

All options are namespaced under `my.*` (e.g., `my.bundles.desktop-hyprland.enable`, `my.devpack.enable`).

### Host Configuration

Hosts are defined in `hosts/<hostname>/` with:
- `configuration.nix` - Main host config
- `hardware-configuration.nix` - Hardware-specific settings
- `home.nix` - Home-manager user configuration (optional)

Host registration happens in `flake-modules/hosts.nix` using `mkSystem` helper:
```nix
nixosConfigurations = {
  hostname = mkSystem ../hosts/hostname/configuration.nix;
};
```

### Common Configuration

The `my.common.enable = true` option (automatically enabled in `flake-modules/hosts.nix`) provides:
- Nix flakes support with experimental features
- Binary caches (nix-community, numtide)
- SSH server with fail2ban
- System-wide packages (vim, neovim, git, curl, sops, age, etc.)
- Timezone (Asia/Taipei) and locale (en_US.UTF-8 with zh_TW extras)
- nftables firewall
- zsh as default shell
- nh (Nix helper) with weekly cleanup
- Custom root CAs (personal homelab and university CAs)

### Secrets Management

Uses **sops-nix** for secret management:
- Default secrets file: `modules/secrets/default.yaml` (relative to feature module)
- Age key: `/etc/ssh/ssh_host_ed25519_key`
- Private secrets repo: `github.com/efficacy38/nix-secret` (shallow clone in flake inputs)

### Key Dependencies

- `nixpkgs-stable` (nixos-25.11) - Primary nixpkgs for systems
- `nixpkgs` (nixos-unstable) - Available as overlay
- `home-manager-stable` - User environment management
- `sops-nix` - Secrets management
- `impermanence` - Stateless system support
- `stylix` - System-wide theming (disabled by default)
- `disko` - Declarative disk management
- `nixos-hardware` - Hardware-specific configurations
- `import-tree` - Automatic module importing
- `flake-parts` - Modular flake structure

### Available Hosts

- `workstation` - Main workstation
- `homelab-1` - Primary homelab server
- `homelab-test` - Testing homelab environment
- `stella` - Laptop with Hyprland desktop, Intel CPU/GPU, gaming setup
- `cc-desktop` - Desktop system
- `cc-container-vps` - Container VPS
- `iso` - Minimal installation ISO

## Important Notes

- This is a NixOS-based system using stable channel (25.11) as primary
- Configuration path is hardcoded to `/etc/nixos/nix-dotfile` in nh settings
- All systems enable unfree packages by default
- Binary cache fallback is enabled for offline/unreachable cache scenarios
- nftables is the firewall backend (not iptables)
