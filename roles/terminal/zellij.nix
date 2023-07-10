{
  config,
  lib,
  ...
}: let
  cfg = config.my.roles.terminal;
in {
  programs.zellij = {
    enable = cfg.enable;
    settings = {
      ui.pane_frames.rounded_corners = true;
      mouse_mode = true;
      # theme = "catppuccin-mocha";
      # themes.catppuccin-mocha = {
      #   bg = "#585b70";
      #   fg = "#cdd6f4";
      #   red = "#f38ba8";
      #   green = "#a6e3a1";
      #   blue = "#89b4fa";
      #   yellow = "#f9e2af";
      #   magenta = "#f5c2e7";
      #   orange = "#fab387";
      #   cyan = "#89dceb";
      #   black = "#585b70";
      #   white = "#cdd6f4";
      # };
      default_layout = "default";
    };
  };

  xdg.configFile."zellij/layouts/default.kdl" = {
    text = ''
      layout {
        pane borderless=true
        pane size=1 borderless=true {
            plugin location="zellij:compact-bar"
        }
      }
    '';
  };
}
