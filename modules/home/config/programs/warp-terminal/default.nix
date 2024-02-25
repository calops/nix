{
  pkgs,
  lib,
  config,
  ...
}: let
  palette = config.my.colors.palette.withHashtag;
in {
  config = lib.mkIf config.my.roles.graphical.enable {
    home.packages = [pkgs.my.warp-terminal];

    xdg.dataFile."warp-terminal/themes/catppuccin.yml".text =
      # yaml
      ''
        accent: '${palette.purple}' # Accent color for UI elements
        background: '${palette.base}' # Terminal background color
        details: darker # Whether the theme is lighter or darker.
        foreground: '${palette.text}' # The foreground color.
        terminal_colors: # Ansi escape colors.
          normal:
            black: '${palette.surface0}'
            red: '${palette.red}'
            green: '${palette.green}'
            yellow: '${palette.yellow}'
            blue: '${palette.blue}'
            magenta: '${palette.purple}'
            cyan: '${palette.mint}'
            white: '${palette.text}'
          bright:
            black: '${palette.surface1}'
            red: '${palette.cherry}'
            green: '${palette.forest}'
            yellow: '${palette.gold}'
            blue: '${palette.navy}'
            magenta: '${palette.violet}'
            cyan: '${palette.teal}'
            white: '${palette.overlay2}'
      '';
  };
}
