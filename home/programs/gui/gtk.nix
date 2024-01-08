{
  lib,
  pkgs,
  roles,
  ...
}: {
    config = lib.mkIf roles.graphical.enable {
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
