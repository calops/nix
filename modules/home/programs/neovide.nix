{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.roles.graphical.enable {
    home.packages = [ pkgs.neovide ];

    xdg.desktopEntries.neovide = lib.mkIf (!pkgs.stdenv.isDarwin) {
      name = "Neovide";
      genericName = "Neovim GUI";
      exec = "neovide";
      terminal = false;
      categories = [
        "Application"
        "Development"
        "IDE"
      ];
    };

    xdg.configFile."neovide/config.toml".source =
      let
        symbols = {
          family = config.my.roles.graphical.fonts.symbols.name;
          style = "Normal";
        };
      in
      (pkgs.formats.toml { }).generate "config.toml" {
        frame = if pkgs.stdenv.isDarwin then "buttonless" else "none";
        font = {
          size = config.my.roles.graphical.fonts.sizes.terminal;
          edging = "subpixelantialias";
          hinting = "full";
          normal = [
            {
              family = config.my.roles.graphical.fonts.monospace.name;
              style = "Thin";
            }
            symbols
          ];
          bold = [
            {
              family = config.my.roles.graphical.fonts.monospace.name;
              style = "SemiBold";
            }
            symbols
          ];
          italic = [
            {
              family = config.my.roles.graphical.fonts.monospace.name;
              style = "Thin Italic";
            }
            symbols
          ];
          bold_italic = [
            {
              family = config.my.roles.graphical.fonts.monospace.name;
              style = "SemiBold Italic";
            }
            symbols
          ];
        };
      };
  };
}
