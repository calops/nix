{ flake, ... }:
{
  imports = [
    flake.homeModules.default
  ];

  my.roles.terminal.enable = true;
  my.roles.ai.enable = true;

  my.roles.graphical = {
    installAllFonts = true;
    terminal = "kitty";
    monitors.primary = {
      name = "Technical Concepts Ltd 34R83Q X2452000226";
      resolution = "3440x1440@170.000";
    };
    niriExtraConfig = # kdl
      ''
        output "Technical Concepts Ltd 34R83Q X2452000226" {
          mode "3440x1440@170.000"
          variable-refresh-rate
        }
      '';
  };

  nix.settings.cores = 22; # keep two cores for the system
}
