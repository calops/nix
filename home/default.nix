{stateVersion, ...}: {
  imports = [
    ./gaming.nix
    ./terminal.nix
    ./graphical.nix
    ./audio.nix
    ./programs
  ];

  config = {
    home.stateVersion = stateVersion;
    programs.home-manager.enable = true;

    xdg.configFile."nixpkgs/config.nix".text = ''
      {
        allowUnfree = true;
        experimentalFeatures = [
          "flakes"
          "nix-command"
        ];
      }
    '';

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };

    home.file.scripts = {
      source = ../scripts;
      recursive = true;
    };

    programs.gpg.enable = true;
  };
}
