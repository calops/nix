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
        buildFlags = ["USE_WAYLAND_GRIM=1"];
      };
    };
  };
}
