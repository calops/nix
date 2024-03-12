{
  config,
  lib,
  nixosConfig ? null,
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

  config = {
    programs.home-manager.enable = true;
    home.stateVersion = config.my.stateVersion;
    home.sessionVariables.FLAKE = config.my.configDir;
    my.stateVersion = lib.my.mkIfNotNull nixosConfig (lib.mkDefault nixosConfig.my.stateVersion);

    programs.gpg.enable = true;
    programs.dircolors.enable = true;
    services.udiskie = {
      enable = true;
      settings.program_options = {
        tray = false; # FIXME: tray icon isn't working on ironbar
      };
    };

    nix.gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
