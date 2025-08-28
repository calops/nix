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
          title-hidden = true;
          font =
            let
              mkFonts = style: [
                {
                  inherit style;
                  family = config.my.roles.graphical.fonts.monospace.name;
                }
                (symbols // { inherit style; })
              ];
            in
            {
              size = config.my.roles.graphical.fonts.sizes.terminal;
              edging = "subpixelantialias";
              hinting = "full";
              normal = mkFonts "Normal";
              bold = mkFonts "Bold";
              italic = mkFonts "Italic";
              bold_italic = mkFonts "Bold Italic";
            };
        };
    };

    stylix.targets.neovide.enable = false;
  };
}
