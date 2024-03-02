{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    home.packages = [pkgs.grim];
    services.flameshot = {
      enable = true;
      package = pkgs.flameshot.overrideAttrs {
        makeFlags = ["CFLAGS=-DUSE_WAYLAND_GRIM"];
      };
    };
  };
}
