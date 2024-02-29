{
  config,
  lib,
  nixosConfig ? null,
  inputs,
  ...
}: {
  options.my = {
    stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "Home Manager state version";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      description = "Location of the nix config directory (this repo)";
    };
  };

  imports = [
    inputs.anyrun.homeManagerModules.default
  ];

  config = {
    programs.home-manager.enable = true;
    home.stateVersion = config.my.stateVersion;
    my.stateVersion = lib.my.mkIfNotNull nixosConfig (lib.mkDefault nixosConfig.my.stateVersion);

    my.configDir =
      if nixosConfig != null
      then "/etc/nixos"
      else "${config.xdg.configHome}/home-manager";

    programs.gpg.enable = true;
    programs.dircolors.enable = true;
    services.udiskie = {
      enable = true;
      settings.program_options = {
        tray = false; # FIXME: tray icon isn't working on ironbar
      };
    };
  };
}
