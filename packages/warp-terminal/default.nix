{pkgs, ...}:
pkgs.appimageTools.wrapType2 {
  name = "warp-terminal";
  src = pkgs.fetchurl {
    url = "https://releases.warp.dev/stable/v0.2024.02.20.08.01.stable_02/Warp-x86_64.AppImage";
    hash = "sha256-p9aLcV20BDJIk4phjXXerSD9b2AwKdbjWSQIs5m7Wsc=";
  };
}
