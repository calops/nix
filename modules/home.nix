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
      guard = { pkgs, ... }: platform: lib.mkIf pkgs.stdenv."is${platform}";
    };

  den.default.includes = [
    den.aspects.hmPlatforms

    den.aspects.programs.stasis
    den.aspects.programs.ssh
    den.aspects.programs.oh-my-posh
    den.aspects.programs.nix-index
    den.aspects.programs._1password
    den.aspects.programs.ai-dev
    den.aspects.programs.bat
    den.aspects.programs.fish
    den.aspects.programs.fzf
    den.aspects.programs.git
    den.aspects.programs.linear
    den.aspects.programs.neovim
    den.aspects.programs.nh
    den.aspects.programs.nushell
    den.aspects.programs.zellij
    den.aspects.programs.aerospace
    den.aspects.programs.sketchybar
    den.aspects.programs.skhd

    {
      homeManager =
        {
          pkgs,
          lib,
          ...
        }:
        {
          config = {
            home.stateVersion = "26.05";

            programs.home-manager.enable = true;
            programs.gpg.enable = true;
            programs.dircolors.enable = true;

            home.programs = [
              pkgs.jq
              pkgs.megacmd
              pkgs.ast-grep
              pkgs.choose
              pkgs.dust
              pkgs.fclones
              pkgs.fd
              pkgs.rm-improved
              pkgs.sshfs
              pkgs.gh
              pkgs.killall
              pkgs.unzip
              pkgs.unrar
              pkgs.yq
              pkgs.pastel
              pkgs.jaq
              pkgs.devenv
              pkgs.uv
            ];

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
        };
    }
    {
      homeManagerLinux =
        { pkgs, ... }:
        {
          home.programs = [
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
