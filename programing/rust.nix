{ config, pkgs, ... }: {
  home.packages =
    let
      inherit pkgs;
      toolchain = pkgs.rustPlatform;
    in
    with pkgs; [
      clippy
      rustfmt
      pkg-config
    ] ++ (with toolchain; [
      cargo
      rustc
      rustLibSrc
    ]);
}
