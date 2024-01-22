{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.roles.graphical;
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
    ./swaync.nix
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
    programs.zathura = {
      enable = true;
      options.font = cfg.fonts.monospace.name;
    };

    services.espanso = {
      enable = true;
      package = pkgs.espanso-wayland.overrideAttrs rec {
        version = "2.2.1";
        rev = "v${version}";
      };
    };

    home.packages = with pkgs;
      [
        wl-clipboard
        google-chrome
        libnotify
      ]
      ++ (
        if cfg.installAllFonts
        then lib.attrsets.mapAttrsToList (name: font: font.package) (import ../../../lib/fonts.nix pkgs)
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
