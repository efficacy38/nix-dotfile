{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  libGL,
  libxkbcommon,
  vulkan-loader,
  wayland,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "flowsurface";
  version = "0.8.6";

  src = fetchurl {
    url = "https://github.com/flowsurface-rs/flowsurface/releases/download/v${version}/flowsurface-x86_64-linux.tar.gz";
    sha256 = "88f731dff75131c760e9d6de609663abe6700de2e13954b8cf87a2ab7e693862";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    libGL
    libxkbcommon
    vulkan-loader
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/flowsurface
    cp -r assets $out/share/flowsurface/
    cp bin/flowsurface $out/bin/flowsurface

    wrapProgram $out/bin/flowsurface \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --set FLOWSURFACE_ASSETS_DIR "$out/share/flowsurface/assets"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Market data visualization application for cryptocurrency trading";
    homepage = "https://github.com/flowsurface-rs/flowsurface";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "flowsurface";
  };
}
