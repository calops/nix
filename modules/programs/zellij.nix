{ ... }:
{
  den.aspects.programs.zellij = {
    homeManager =
      { ... }:
      {
        programs.zellij = {
          enable = true;
          enableFishIntegration = false;
          settings = {
            ui.pane_frames.rounded_corners = true;
            mouse_mode = true;
            default_layout = "default";
            show_startup_tips = false;
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
  };
}
