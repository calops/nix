{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  config = lib.mkIf config.my.roles.graphical.enable {
    programs.neovide = {
      enable = true;
      package = inputs.nightly-tools.packages.${pkgs.system}.neovide;
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
  };
}
