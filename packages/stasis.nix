{
  pkgs,
  inputs,
  ...
}:
pkgs.lib.mkIf pkgs.stdenv.isLinux (
  pkgs.rustPlatform.buildRustPackage {
    pname = "stasis";
    version = "0.1.0";

    src = inputs.stasis;
    cargoHash = "sha256-pdknkH83ONwSAVphUVGceV0vk/69tsVG9wu4ULnd7u8=";

    buildInputs = [
      pkgs.dbus
      pkgs.udev
      pkgs.libinput
    ];

    nativeBuildInputs = [
      pkgs.pkg-config
    ];

    dbus = pkgs.dbus;
    doCheck = false;
  }
)
