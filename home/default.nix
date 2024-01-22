{
  config,
  lib,
  nixosConfig ? null,
  ...
}: {
  imports = [
    ./gaming.nix
    ./terminal.nix
    ./graphical.nix
    ./audio.nix
    ./programs
  ];

  config = {
    programs.home-manager.enable = true;
    my = {isNixOs = false;} // lib.mkIf (nixosConfig != null) nixosConfig.my;
    home.stateVersion = config.my.stateVersion;

    xdg.configFile."nixpkgs/config.nix".text = ''
      {
        allowUnfree = true;
        experimentalFeatures = [
          "flakes"
          "nix-command"
        ];
      }
    '';

    home.file.scripts = {
      source = ../scripts;
      recursive = true;
    };

    programs.gpg.enable = true;
    services.udiskie.enable = true;
  };
}
