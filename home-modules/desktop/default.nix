{ ... }@args:
{
  imports = [
    ./apps.nix
    ./scripts
    ./kde.nix
    (import ./firefox.nix args)
  ];
}
