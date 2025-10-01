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
    cargoHash = "sha256-K3pyzv4s4lS8u7kAGgogVbixXk3Pd7gCmhmSYcReve8=";

    buildInputs = [
      pkgs.dbus
      pkgs.udev
      pkgs.libinput
    ];

    nativeBuildInputs = [
      pkgs.pkg-config
    ];

    dbus = pkgs.dbus;
  }
)
