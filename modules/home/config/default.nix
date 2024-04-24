{
  config,
  lib,
  nixosConfig ? null,
  darwinConfig ? null,
  ...
}:
{
  options.my = {
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos";
      description = "Location of the nix config directory (this repo)";
    };
    configType = lib.mkOption {
      type = lib.types.str;
      default =
        if config.my.isNixos then
          "nixos"
        else if config.my.isDarwin then
          "darwin"
        else
          "standalone";
    };
    isNixos = lib.mkOption {
      type = lib.types.bool;
      default = nixosConfig != null;
      readOnly = true;
    };
    isDarwin = lib.mkOption {
      type = lib.types.bool;
      default = darwinConfig != null;
      readOnly = true;
    };
  };

  config = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
    home.sessionVariables.FLAKE = config.my.configDir;

    programs.gpg.enable = true;
    programs.dircolors.enable = true;
    services.udiskie = lib.mkIf (!config.my.isDarwin) {
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
