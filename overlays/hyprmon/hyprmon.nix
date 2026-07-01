{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      hyprmon = prev.hyprmon.overrideAttrs (
        finalAttrs: previousAttrs: {
          version = "0.0.17-unstable-2026-07-01";

          src = final.fetchFromGitHub {
            owner = "erans";
            repo = "hyprmon";
            rev = "abee6b59df062b4bda3be643fafa6e3e78cea59f";
            hash = "sha256-mCtwb8NwMN+tmOi1vrnbuavR5HKoZdy3CSyU5cxPbqg=";
          };

          vendorHash = "sha256-U2fw/1tnRwmd9qzEcrMduZbbNU67NbDhG2Id5IHj5js=";

          meta = previousAttrs.meta // {
            changelog = "https://github.com/erans/hyprmon/commits/${finalAttrs.src.rev}";
          };
        }
      );
    })
  ];
}
