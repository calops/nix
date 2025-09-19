{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  palette = config.my.colors.palette.asHexWithHashtag;
  wallpaper = config.stylix.image;
in
{
  imports = [ inputs.niri-caelestia-shell.homeManagerModules.default ];

  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.quickshell = {
      enable = true;
      activeConfig = null;
      systemd.enable = true;
    };

    home.file."Pictures/Wallpapers/main.png".source = config.stylix.image;

    xdg.configFile."quickshell".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/quickshell/config";
  };
}
