{ den, lib, ... }:
{
  flake-file.inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.hmPlatforms =
    { aspect-chain, ... }:
    den._.forward {
      each = [
        "Linux"
        "Darwin"
      ];
      fromClass = platform: "homeManager${platform}";
      intoClass = _: "homeManager";
      intoPath = _: [ ];
      fromAspect = _: lib.head aspect-chain;
      guard =
        # Arguments need to be explicitly listed for den to forward them to the module
        {
          pkgs,
          config,
          colors,
          inputs',
          ...
        }:
        platform: lib.mkIf pkgs.stdenv."is${platform}";
    };

  den.default.includes = [
    den.aspects.hmPlatforms

    den.aspects.programs._.stasis
    den.aspects.programs._.ssh
    den.aspects.programs._.oh-my-posh
    den.aspects.programs._.nix-index
    den.aspects.programs._._1password
    den.aspects.programs._.ai-dev
    den.aspects.programs._.bat
    den.aspects.programs._.fish
    den.aspects.programs._.fzf
    den.aspects.programs._.git
    den.aspects.programs._.linear
    den.aspects.programs._.neovim
    den.aspects.programs._.nh
    den.aspects.programs._.nushell
    den.aspects.programs._.zellij
    den.aspects.programs._.aerospace
    den.aspects.programs._.sketchybar
    den.aspects.programs._.skhd

    {
      homeManager =
        {
          pkgs,
          lib,
          ...
        }:
        {
          home.stateVersion = "26.05";

          programs.home-manager.enable = true;
          programs.gpg.enable = true;
          programs.dircolors.enable = true;

          home.packages = [
            pkgs.jq
            pkgs.megacmd
            pkgs.ast-grep
            pkgs.choose
            pkgs.dust
            pkgs.fclones
            pkgs.fd
            pkgs.rm-improved
            pkgs.sshfs
            pkgs.killall
            pkgs.unzip
            pkgs.unrar
            pkgs.yq
            pkgs.pastel
            pkgs.jaq
            pkgs.devenv
            pkgs.uv
          ];

          programs.gh = {
            enable = true;
            extensions = [ pkgs.gh-stack ];
          };

          programs.btop = {
            enable = true;
            package = pkgs.btop.override { cudaSupport = true; };
            settings = {
              theme_background = false;
            };
          };

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
            config.global.hide_env_diff = true;
          };

          programs.eza = {
            enable = true;
            enableFishIntegration = false;
            icons = "auto";
            git = true;
          };

          programs.zoxide = {
            enable = true;
            enableFishIntegration = true;
          };

          programs.ripgrep.enable = true;

          nix.package = lib.mkDefault pkgs.nix;
          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };

          xdg.enable = true;
        };
    }
    {
      homeManagerLinux =
        { pkgs, ... }:
        {
          home.packages = [
            pkgs.dtrx
            pkgs.dysk
            pkgs.xcp
          ];

          services.network-manager-applet.enable = true;
          services.gnome-keyring.enable = true;

          services.udiskie = {
            enable = true;
            tray = "auto";
          };
        };
    }
  ];
}
