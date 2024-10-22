{ config, ... }:
let
  cfg = config.my.roles.graphical;
in
{
  programs.kitty = {
    enable = cfg.enable && cfg.terminal == "kitty";
    settings = {
      font_size = cfg.fonts.sizes.terminal;
      font_family = cfg.fonts.monospace.name;
      undercurl_style = "thick-sparse";
      # TODO: uncomment when next release is out
      # cursor_trail = 3;

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
