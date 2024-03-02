{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.nix-index.enable = true;

    home.packages = with pkgs; [
      megatools
      ast-grep
      choose
      du-dust
      dysk
      fclones
      fd
      rargs
      ripgrep
      rm-improved
      sshfs
      xcp
      gh
      killall
      unzip
      unrar
      yq
      pastel
    ];

    programs.btop = {
      enable = config.my.roles.terminal.enable;
      settings = {
        theme_background = false;
      };
    };

    programs.direnv = {
      enable = config.my.roles.terminal.enable;
      nix-direnv.enable = true;
    };

    programs.eza = {
      enable = config.my.roles.terminal.enable;
      icons = true;
      git = true;
    };

    programs.helix = {
      enable = true;
      settings = {
        theme = "catppuccin_mocha";
      };
    };
    stylix.targets.helix.enable = false;

    programs.zoxide = {
      enable = config.my.roles.terminal.enable;
      enableFishIntegration = true;
    };
  };
}
