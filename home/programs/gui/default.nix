{
  pkgs,
  roles,
  lib,
  ...
}: let
  cfg = roles.graphical;
in {
  imports = [
    ./element.nix
    ./wezterm
    ./kitty.nix
    ./ulauncher
    ./gtk.nix
    ./hyprland.nix
    ./firefox.nix
    ./waybar.nix
    ./eww
  ];

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    stylix = {
      fonts = {
        sizes = {
          terminal = cfg.fonts.sizes.terminal;
          applications = cfg.fonts.sizes.applications;
        };

        serif = cfg.fonts.serif;
        sansSerif = cfg.fonts.sansSerif;
        monospace = cfg.fonts.monospace;
        emoji = cfg.fonts.emoji;
      };
      cursor = {
        name = "Catppuccin-Mocha-Peach-Cursors";
        size = 32;
        package = pkgs.catppuccin-cursors.mochaPeach;
      };
    };

    programs.mpv.enable = true;
    programs.zathura.enable = true;

    home.packages = with pkgs;
      [
        wl-clipboard
        google-chrome
      ]
      ++ (
        if cfg.installAllFonts
        then lib.attrsets.mapAttrsToList (name: font: font.package) lib.my.fonts
        else
          with cfg.fonts; [
            monospace.package
            serif.package
            sansSerif.package
            emoji.package
          ]
      );
  };
}
