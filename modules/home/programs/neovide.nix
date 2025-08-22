{
  lib,
  config,
  pkgs,
  perSystem,
  ...
}:
{
  config = lib.mkIf config.my.roles.graphical.enable {
    programs.neovide = {
      enable = true;
      package = perSystem.self.neovide;
      settings =
        let
          symbols = {
            family = config.my.roles.graphical.fonts.symbols.name;
            style = "Normal";
          };
        in
        {
          frame = if pkgs.stdenv.isDarwin then "buttonless" else "none";
          font = {
            size = config.my.roles.graphical.fonts.sizes.terminal;
            edging = "subpixelantialias";
            hinting = "full";
            normal = [
              {
                family = config.my.roles.graphical.fonts.monospace.name;
                style = "Normal";
              }
              symbols
            ];
            bold = [
              {
                family = config.my.roles.graphical.fonts.monospace.name;
                style = "Bold";
              }
              symbols
            ];
            italic = [
              {
                family = config.my.roles.graphical.fonts.monospace.name;
                style = "Italic";
              }
              symbols
            ];
            bold_italic = [
              {
                family = config.my.roles.graphical.fonts.monospace.name;
                style = "Bold Italic";
              }
              symbols
            ];
          };
        };
    };

    stylix.targets.neovide.enable = false;
  };
}
