{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    nix-secrets = {
      url = "git+ssh://git@github.com/efficacy38/nix-secret.git?ref=main&shallow=1";
      # url = "git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=main&shallow=1";
      inputs = { };
      flake = false;
    };

    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      #url = "https://flakehub.com/f/Svenum/Solaar-Flake/0.1.1.tar.gz" # uncomment line for solaar version 1.1.13
      #url = "github:Svenum/Solaar-Flake/main"; # Uncomment line for latest unstable version
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      ...
    }@inputs:
    let
      pkgs-stable = import nixpkgs-stable {
        system = "x86_64-linux";
      };
      common-modules = [
        # use nix-index-database instead of run nix-index individually
        inputs.nix-index-database.nixosModules.nix-index
        # optional to also wrap and install comma
        { programs.nix-index-database.comma.enable = true; }
      ];
    in
    {
      nixosConfigurations = {
        phoenixton = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs pkgs-stable; };
          modules = [
            ./hosts/phoenixton/configuration.nix
            inputs.nixos-hardware.nixosModules.common-cpu-amd
            inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
            inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
            inputs.nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
            inputs.nixos-hardware.nixosModules.common-pc-ssd
            inputs.nixos-hardware.nixosModules.common-hidpi
            inputs.solaar.nixosModules.default
            inputs.impermanence.nixosModules.impermanence
          ] ++ common-modules;
        };

        cc-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/cc-desktop/configuration.nix
          ] ++ common-modules;
        };

        dorm-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/dorm-desktop/configuration.nix
            inputs.nixos-hardware.nixosModules.common-cpu-amd
            inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
            inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
            inputs.nixos-hardware.nixosModules.common-pc-ssd
          ] ++ common-modules;
        };

        workstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/workstation/configuration.nix
          ] ++ common-modules;
        };

        homelab-1 = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/workstation/configuration.nix
          ] ++ common-modules;
        };

        # INFO: iso building flake
        minimal-latest-iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (
              {
                pkgs,
                modulesPath,
                lib,
                ...
              }:
              {
                imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
                environment.systemPackages = with pkgs; [
                  wget
                  curl
                  # dhclient
                  u-root-cmds
                  # iw tui
                  impala
                ];
                services.connman.wifi.backend = "iwd";
                # disable wpa_supplicant, use iwd as alternative
                networking.wireless.enable = false;
                networking.wireless.iwd.enable = true;
                environment.variables.EDITOR = "vim";
                boot.supportedFilesystems = lib.mkForce [
                  "btrfs"
                  "reiserfs"
                  "vfat"
                  "f2fs"
                  "xfs"
                  "ntfs"
                  "cifs"
                  "zfs"
                ];
              }
            )
          ];
        };
      };
    };
}
