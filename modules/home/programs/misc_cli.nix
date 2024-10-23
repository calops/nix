{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = with pkgs; [
      megatools
      ast-grep
      choose
      du-dust
      dysk
      fclones
      fd
      rargs
      rm-improved
      sshfs
      xcp
      gh
      killall
      unzip
      unrar
      yq
      pastel
      jaq
      devenv
    ];

    programs.nix-index-database.comma.enable = true;

    programs.btop = {
      enable = config.my.roles.terminal.enable;
      package = pkgs.btop.override { cudaSupport = true; };
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
      enableFishIntegration = false;
      icons = "auto";
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

    programs.ripgrep.enable = true;
  };
}
