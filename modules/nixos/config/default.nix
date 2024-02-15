{
  config,
  lib,
  ...
}: {
  options.my.stateVersion = lib.mkOption {
    type = lib.types.str;
    description = "NixOS state version";
  };

  config = {
    system.stateVersion = config.my.stateVersion;
    hardware.enableAllFirmware = true;

    nix = {
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    services.udisks2.enable = true;
    services.openssh.enable = true;

    programs.fish.enable = true;
    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
