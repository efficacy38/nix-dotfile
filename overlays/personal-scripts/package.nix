{
  pkgs,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "personal-script";
  version = "0.1.0";

  src = builtins.path {
    name = "personal-script";
    path = ./.;
  };

  dontBuild = true;

  buildInputs = with pkgs; [
    openfortivpn
    boxes
    bash
    tailscale
    # control systemd-resolved
    systemd
  ];

  # TODO: maybe writeShellScriptBin or writeShellScriptApplication is better
  installPhase = ''
    mkdir -p $out/bin/modules/
    cp cscc_work.sh $out/bin/cscc_work
    cp modules/* $out/bin/modules
    chmod +x -R $out/bin
  '';

  meta = with lib; {
    description = "my personal binary snippet";
    license = licenses.mit;
  };
}
