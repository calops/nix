{
  config,
  lib,
  ...
}: let
  cfg = config.my.roles.terminal;
in {
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        ui.pane_frames.rounded_corners = true;
        mouse_mode = true;
        default_layout = "default";
      };
    };

    xdg.configFile."zellij/layouts/default.kdl".text = ''
      layout {
        pane borderless=true
        pane size=1 borderless=true {
            plugin location="zellij:compact-bar"
        }
      }
    '';
  };
}
