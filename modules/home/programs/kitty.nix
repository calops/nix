{ config, ... }:
let
  cfg = config.my.roles.graphical;
  palette = config.my.colors.palette;
in
{
  programs.kitty = {
    enable = cfg.enable && cfg.terminal == "kitty";
    settings = {
      font_size = cfg.fonts.sizes.terminal;
      font_family = cfg.fonts.monospace.name;
      bold_font = "${cfg.fonts.monospace.name} Bold";
      italic_font = "${cfg.fonts.monospace.name} Italic";
      bold_italic_font = "${cfg.fonts.monospace.name} Bold Italic";
      undercurl_style = "thick-sparse";
      "modify_font underline_position" = "+2";
      "modify_font underline_thickness" = "2px";
    };
    keybindings = {
      "ctrl+tab" = "no_op";
      "ctrl+shift+tab" = "no_op";
      "ctrl+shift+g" = "no_op";
      "ctrl+t" = "no_op";
      "ctrl+shift+t" = "no_op";
    };
  };
}
