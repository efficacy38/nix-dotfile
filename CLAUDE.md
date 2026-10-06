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
- `features/system/` - System-level configs (impermanence, zram, firmware, network, virtualization, backup, etc.)
- `features/desktop/` - Desktop environment features (sessions in `desktop-manager.nix`, `gaming.nix`, `fprintd.nix`, `battery-health.nix`, `zen.nix`, `ssh-tunnels.nix`, shared config in `common.nix`)
- `features/devpack/` - Development tools (editor, shell, tools, work)

**Bundles** (pre-configured sets of features):
- `bundles/desktop.nix` - Desktop setup (session chosen via `my.bundles.desktop.session`)
- `bundles/general.nix` - General dev/user setup (minimal + git, just, utilities, agents, podman, k8s)
- `bundles/homelab.nix` - Homelab-specific setup
- `bundles/minimal.nix` - Minimal system
- `bundles/server.nix` - Server configuration
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

All options are namespaced under `my.*` (e.g., `my.bundles.desktop.enable`, `my.devpack.enable`).

### Host Configuration

Hosts are defined in `hosts/<hostname>/` using a layered split:

- `default.nix` - Composition entrypoint; imports the files below that exist
- `configuration.nix` - Host-local overrides only (networking: hostname, interfaces, static IPs, `extraHosts`, firewall; `system.stateVersion`)
- `platform.nix` - System/hardware layer (nixos-hardware imports, kernel packages, filesystems + kernel modules, udev, system services, root SSH keys, `my.system.*`, hardware `my.desktop.*`, system packages/programs, `nixpkgs.hostPlatform`)
- `profile.nix` - Application/persona layer (which `my.bundles.*`, `my.users.*`, `my.devpack.*`, `my.common-server`, and app-level `my.desktop.*` the machine runs)
- `hardware-configuration.nix` - Generated hardware scan (optional)
- `home.nix` - Home-manager user configuration (optional)

`profile.nix` is portable: `stella-nspawn` imports `../stella/profile.nix` to reuse stella's user/desktop persona without inheriting its system/hardware layer.

Host registration happens in `flake-modules/hosts.nix` using the `mkSystem` helper, passing the host directory (Nix resolves `default.nix`):

```nix
nixosConfigurations = {
  hostname = mkSystem ../hosts/hostname;
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
- Observability/performance tools, always on (formerly `observability.nix`)
- systemd-oomd, user slices only, toggled by `my.system.oomd.enable` (formerly `oomd.nix`)
- Server extras toggled by `my.common-server.enable`: rsyncd + mosh (formerly `common-server.nix`)
- A default `efficacy38` user (type `minimal`, admin), overridable per host (formerly `bundles/common.nix`)

### Secrets Management

Uses **sops-nix** for secret management:
- Default secrets file: `modules/secrets/default.yaml` (relative to feature module)
- Age key: `/etc/ssh/ssh_host_ed25519_key`
- Private secrets repo: `github.com/efficacy38/nix-secret` (shallow clone in flake inputs)

### Key Dependencies

- `nixpkgs` (nixos-26.05) - Primary nixpkgs for systems and user environments
- `home-manager-stable` - User environment management
- `sops-nix` - Secrets management
- `impermanence` - Stateless system support
- `stylix` - System-wide theming (disabled by default)
- `nixos-hardware` - Hardware-specific configurations
- `import-tree` - Automatic module importing
- `flake-parts` - Modular flake structure

### Available Hosts

- `workstation` - Main workstation
- `homelab-1` - Primary homelab server
- `homelab-test` - Testing homelab environment
- `stella` - Laptop with Hyprland desktop, Intel CPU/GPU, gaming setup
- `stella-nspawn` - systemd-nspawn container reusing `stella`'s `profile.nix`
- `cc-desktop` - Desktop system
- `cc-container-vps` - Container VPS
- `minimum` - Unregistered template host for new machines
- `iso` - Minimal installation ISO

## Important Notes

- This is a NixOS-based system using stable channel (26.05) as primary
- Configuration path is hardcoded to `/etc/nixos/nix-dotfile` in nh settings
- All systems enable unfree packages by default
- Binary cache fallback is enabled for offline/unreachable cache scenarios
- nftables is the firewall backend (not iptables)
