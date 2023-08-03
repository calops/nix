{
  config,
  lib,
  pkgs,
  configurationName,
  ...
}: let
  cfg = config.my.roles.terminal;
  palette = config.my.colors.palette;
  nvimDir = "${config.home.homeDirectory}/.config/home-manager/programs/cli/neovim";
  my = {
    # We want gcc to override the system's one or treesitter throws a fit
    neovim = pkgs.neovim-nightly.overrideAttrs (attrs: {
      disallowedReferences = [];
      nativeBuildInputs = attrs.nativeBuildInputs ++ [pkgs.makeWrapper];
      postFixup = ''
        wrapProgram $out/bin/nvim --prefix PATH : ${lib.makeBinPath [pkgs.gcc]}
      '';
    });
  };
in
  with lib; {
    config = mkIf cfg.enable {
      programs.neovim = {
        enable = true;
        package = my.neovim;
        defaultEditor = true;
        extraPackages = with pkgs; [
          alejandra
          fzf
          nixd
          nodePackages.prettier
          shfmt
          sqlfluff
          stylua
        ];
      };

      xdg.configFile = {
        # Raw symlink to the plugin manager lock file, so that it stays writeable
        "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/lazy-lock.json";
        "nvim/lua/nix/palette.lua".text = "return ${lib.generators.toLua {} palette}";
        "nvim" = {
          source = ./config;
          recursive = true;
        };
        "home-manager/.nixd.json".text = builtins.toJSON {
          options = {
            enable = true;
            target = {
              installable = ".#homeConfigurations.${configurationName}.options";
            };
          };
        };
      };

      stylix.targets.vim.enable = false;

      home.activation.neovim = lib.hm.dag.entryAfter ["linkGeneration"] ''
        #! /bin/sh
        STATE_DIR=~/.local/state/nix/
        STATE_FILE=$STATE_DIR/lazy-lock-checksum
        LOCK_FILE=~/.config/nvim/lazy-lock.json

        if [ ! -d $STATE_DIR ]; then
          mkdir -p $STATE_DIR
        fi

        if [ ! -f $STATE_FILE ]; then
          touch $STATE_FILE
        fi

        if [ "$(cat $STATE_FILE)" != "$(nix-hash $LOCK_FILE)" ]; then
          echo "Syncing neovim plugins"
          PATH="$PATH:${pkgs.git}/bin" $DRY_RUN_CMD ${lib.getExe my.neovim} --headless "+Lazy! update" +qa
          nix-hash $LOCK_FILE > $STATE_FILE
        else
          $VERBOSE_ECHO "Neovim plugins already synced, skipping"
        fi
      '';
    };
  }
