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
  ];

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.pointerCursor = {
      name = "Catppuccin-Mocha-Peach-Cursors";
      size = 32;
      package = pkgs.catppuccin-cursors.mochaPeach;
      gtk.enable = true;
    };

    stylix.fonts = {
      sizes = {
        terminal = cfg.fonts.sizes.terminal;
        applications = cfg.fonts.sizes.applications;
      };

      serif = cfg.fonts.serif;
      sansSerif = cfg.fonts.sansSerif;
      monospace = cfg.fonts.monospace;
      emoji = cfg.fonts.emoji;
    };

    programs.mpv.enable = true;

    home.packages =
      if cfg.installAllFonts
      then lib.attrsets.mapAttrsToList (name: font: font.package) lib.my.fonts
      else
        with cfg.fonts; [
          monospace.package
          serif.package
          sansSerif.package
          emoji.package
        ];
  };
}
