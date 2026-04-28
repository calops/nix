{ ... }:
{
  den.aspects.programs.provides.kitty = {
    homeManager =
      { config, pkgs, ... }:
      {
        programs.kitty = {
          enable = true;
          enableGitIntegration = true;

          settings = {
            font_size = config.fonts.sizes.terminal;
            font_family = config.fonts.monospace.name;
            bold_font = "${config.fonts.monospace.name} Bold";
            italic_font = "${config.fonts.monospace.name} Italic";
            bold_italic_font = "${config.fonts.monospace.name} Bold Italic";

            undercurl_style = "thick-sparse";
            cursor_trail = 3;
            hide_window_decorations = if pkgs.stdenv.isDarwin then "titlebar-only" else "yes";
            cursor_blink_interval = "-1 ease-in-out";
            macos_hide_from_tasks = true;
            scrollback_lines = 10000;
            scrollback_fill_enlarged_window = true;
            show_hyperlink_targets = true;
            strip_trailing_spaces = "always";
            notify_on_cmd_finish = "invisible 15";
            clipboard_control = "write-clipboard write-primary read-clipboard read-primary";

            "modify_font underline_position" = "+2";
            "modify_font underline_thickness" = "2px";

            "symbol_map U+E000-U+F8FF" = config.fonts.symbols.name;
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

        xdg.configFile."kitty/quick-access-terminal.conf".text = ''
          background_opacity 0.85
          background_blur 60
        '';
      };
  };
}
