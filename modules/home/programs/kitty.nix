{
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.roles.graphical;
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
      cursor_trail = 3;
      hide_window_decorations = if pkgs.stdenv.isDarwin then "titlebar-only" else "yes";
      cursor_blink_interval = "-1 ease-in-out";
      macos_hide_from_tasks = true;

      "modify_font underline_position" = "+2";
      "modify_font underline_thickness" = "2px";
      "modify_font cell_width" = "${toString (cfg.fonts.sizes.terminalCell.width * 100)}%";
    };
    keybindings = {
      "ctrl+tab" = "no_op";
      "ctrl+shift+tab" = "no_op";
      "ctrl+shift+g" = "no_op";
      "ctrl+t" = "no_op";
      "ctrl+shift+t" = "no_op";
      "alt+l" = "no_op";
      "alt+w" = "no_op";

      "ctrl+up" = "scroll_to_prompt -1";
      "ctrl+down" = "scroll_to_prompt 1";
    };
  };
}
