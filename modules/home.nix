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

  den.schema.host.includes = [ den.aspects.hmPlatforms ];

  den.schema.user.includes = [ den.aspects.homeDefault ];
  den.schema.home.includes = [ den.aspects.homeDefault ];

  den.aspects.homeDefault.includes = [
    den.aspects.programs._.stasis
    den.aspects.programs._.ssh
    den.aspects.programs._.oh-my-posh
    den.aspects.programs._.nix-index
    den.aspects.programs._.onepassword
    den.aspects.programs._.bat
    den.aspects.programs._.fish
    den.aspects.programs._.fzf
    den.aspects.programs._.git
    den.aspects.programs._.linear

    {
      homeManager =
        { config, lib, ... }:
        {
          options.home.configDir = lib.mkOption {
            type = lib.types.str;
            default = "${config.home.homeDirectory}/nix";
            description = "Path to the user-managed Nix configuration checkout.";
          };
        };
    }

    # gh with a config per directory tree, e.g. a work account under ~/terabase. Wrapping the
    # package rather than a shell function makes it hold for every caller: bash, scripts, gh
    # extensions and git's credential helper, which runs `gh auth git-credential` inside the repo.
    # Only declared directories count: a config found by searching upwards would let any checkout
    # pick gh's pager, browser or token.
    {
      homeManager =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.gh;
          yamlFormat = pkgs.formats.yaml { };
          home = config.home.homeDirectory;
          # Longest first, so a directory nested in another declared one takes precedence.
          roots = lib.sort (a: b: lib.stringLength a > lib.stringLength b) (lib.attrNames cfg.configDirs);
          wrapper = pkgs.writeShellScriptBin "gh" ''
            if [ -z "''${GH_CONFIG_DIR:-}" ] && here=$(pwd -P 2>/dev/null); then
              for root in ${lib.escapeShellArgs roots}; do
                real=$(cd -P "$root" 2>/dev/null && pwd -P) || continue
                case "$here/" in
                  "$real"/*)
                    export GH_CONFIG_DIR="$root/.gh"
                    break
                    ;;
                esac
              done
            fi
            exec ${lib.getExe pkgs.gh} "$@"
          '';
        in
        {
          options.programs.gh.configDirs = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
                options.settings = lib.mkOption {
                  inherit (yamlFormat) type;
                  default = { };
                  description = "Written to {file}`<directory>/.gh/config.yml`.";
                };
              }
            );
            default = { };
            example = lib.literalExpression ''{ "''${config.home.homeDirectory}/work".settings.git_protocol = "ssh"; }'';
            description = ''
              Directories under which gh uses its own config, `<directory>/.gh`, instead of the
              default one. Its `hosts.yml`, which holds the accounts, stays gh's to write.
            '';
          };

          config = lib.mkIf (cfg.configDirs != { }) {
            assertions = map (root: {
              assertion = lib.hasPrefix "${home}/" root;
              message = "programs.gh.configDirs: ${root} is not under ${home}.";
            }) roots;

            programs.gh.package = pkgs.symlinkJoin {
              name = "gh-${pkgs.gh.version}";
              # The wrapper comes first, so its bin/gh wins over the real one.
              paths = [
                wrapper
                pkgs.gh
              ];
              inherit (pkgs.gh) version;
              meta = pkgs.gh.meta // {
                mainProgram = "gh";
              };
            };

            home.file = lib.mapAttrs' (
              root: dir:
              lib.nameValuePair "${lib.removePrefix "${home}/" root}/.gh/config.yml" {
                source = yamlFormat.generate "gh-config.yml" ({ version = "1"; } // dir.settings);
              }
            ) cfg.configDirs;
          };
        };
    }

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
          config,
          pkgs,
          lib,
          ...
        }:
        {
          home.stateVersion = "26.11";
          home.enableNixpkgsReleaseCheck = false;

          programs.home-manager.enable = true;
          programs.gpg.enable = true;
          programs.dircolors.enable = true;

          home.packages = [
            config.nix.package
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
