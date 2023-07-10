{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.roles.graphical;
in
  with lib; {
    config = mkIf cfg.enable {
      gtk = {
        enable = true;
        # theme = {
        #   name = "Catppuccin-Mocha-Compact-Peach-Dark";
        #   package = pkgs.catppuccin-gtk.override {
        #     accents = ["peach"];
        #     size = "compact";
        #     tweaks = ["rimless" "black"];
        #     variant = "mocha";
        #   };
        # };
      };
      qt = {
        enable = true;
        platformTheme = "gtk";
      };
    };
  }
