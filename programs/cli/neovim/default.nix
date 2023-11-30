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
  nvim-pkg = pkgs.neovim-nightly;
in
  with lib; {
    config = mkIf cfg.enable {
      programs.neovim = {
        enable = true;
        package = nvim-pkg;
        defaultEditor = true;
        extraPackages = with pkgs; [
          alejandra
          fzf
          nixd
          nodePackages.prettier
          shfmt
          sqlfluff
          stylua
          rust-analyzer
        ];
        plugins = [
          pkgs.vimPlugins.lazy-nvim
        ];
      };

      xdg.configFile = {
        # Raw symlink to the plugin manager lock file, so that it stays writeable
        "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/lazy-lock.json";
        "nvim/lua/nix/palette.lua".text = "return ${lib.generators.toLua {} palette}";
        "nvim/lua/nix/tools.lua".text = ''
          return {
          	gcc = '${lib.getExe pkgs.gcc}';
          }
        '';
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
        #! /bin/bash
        STATE_DIR=~/.local/state/nix/
        STATE_FILE=$STATE_DIR/lazy-lock-checksum
        LOCK_FILE=~/.config/nvim/lazy-lock.json
        HASH=$(nix-hash --flat $LOCK_FILE)

        if [ ! -d $STATE_DIR ]; then
          mkdir -p $STATE_DIR
        fi

        if [ ! -f $STATE_FILE ]; then
          touch $STATE_FILE
        fi

        if [ "$(cat $STATE_FILE)" != "$HASH" ]; then
          echo "Syncing neovim plugins"
          PATH="$PATH:${pkgs.git}/bin" $DRY_RUN_CMD ${lib.getExe nvim-pkg} --headless "+Lazy! restore" +qa
          $DRY_RUN_CMD echo $HASH >$STATE_FILE
        else
          $VERBOSE_ECHO "Neovim plugins already synced, skipping"
        fi
      '';
    };
  }
