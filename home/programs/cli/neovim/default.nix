{
  config,
  lib,
  pkgs,
  ...
}: let
  palette = config.my.colors.palette;
  nvimDir = "${config.my.roles.configDir}/home/programs/cli/neovim";
in {
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
      defaultEditor = true;
      extraPackages = with pkgs; [
        alejandra
        black
        cmake
        fzf
        gcc
        gnumake
        isort
        lua-language-server
        nixd
        nodejs
        prettierd
        (fenix.complete.withComponents [
          "cargo"
          "clippy"
          "rust-src"
          "rustc"
          "rustfmt"
          "rust-analyzer"
        ])
        shfmt
        # sqlfluff
        sqlite
        stylua
        vscode-extensions.vadimcn.vscode-lldb.adapter
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
        vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'

        return {
          gcc = '${lib.getExe pkgs.gcc}';
        }
      '';
      "nvim" = {
        source = ./config;
        recursive = true;
      };
      "${config.home.homeDirectory}/nix/.nixd.json".text = builtins.toJSON {
        options = {
          enable = true;
          target = {
            installable =
              if config.my.isNixOs
              then ".#nixosConfigurations.${config.my.configurationName}.options"
              else ".#homeConfigurations.${config.my.configurationName}.options";
          };
        };
      };
    };

    stylix.targets.vim.enable = false;

    home.activation.neovim = lib.hm.dag.entryAfter ["linkGeneration"] ''
      #! /bin/bash
      NVIM_WRAPPER=~/.nix-profile/bin/nvim
      STATE_DIR=~/.local/state/nix/
      STATE_FILE=$STATE_DIR/lazy-lock-checksum
      LOCK_FILE=~/.config/nvim/lazy-lock.json
      HASH=$(nix-hash --flat $LOCK_FILE)

      [ ! -d $STATE_DIR ] && mkdir -p $STATE_DIR
      [ ! -f $STATE_FILE ] && touch $STATE_FILE

      if [ "$(cat $STATE_FILE)" != "$HASH" ]; then
        echo "Syncing neovim plugins"
        PATH="$PATH:${pkgs.git}/bin" $DRY_RUN_CMD $NVIM_WRAPPER --headless "+Lazy! restore" +qa
        $DRY_RUN_CMD echo $HASH >$STATE_FILE
      else
        $VERBOSE_ECHO "Neovim plugins already synced, skipping"
      fi
    '';
  };
}
