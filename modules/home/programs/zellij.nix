{ config, lib, ... }:
{
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.zellij = {
      # FIXME: why the fuck is it opening by default?
      enable = false;
      settings = {
        ui.pane_frames.rounded_corners = true;
        mouse_mode = true;
        default_layout = "default";
      };
    };

    xdg.configFile."zellij/layouts/default.kdl".text = # kdl
      ''
        layout {
          pane borderless=true
          pane size=1 borderless=true {
              plugin location="zellij:compact-bar"
          }
        }
      '';
  };
}
