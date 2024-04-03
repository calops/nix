{
  config,
  lib,
  pkgs,
  ...
}: let
  palette = config.my.colors.palette;
  nvimDir = "${config.my.configDir}/modules/home/config/programs/neovim";
  rustToolchain = pkgs.fenix.complete.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
    "rust-analyzer"
  ];
  nvimPackage = pkgs.symlinkJoin {
    name = "neovim-with-ld-path";
    paths = [pkgs.neovim-nightly];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/nvim --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [
        pkgs.libgit2
        pkgs.gpgme
      ]}"
    '';
  };
in {
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.neovim = {
      enable = true;
      package = nvimPackage;
      defaultEditor = true;
      extraPackages = with pkgs;
        [
          # Formatters
          alejandra # Nix
          black # Python
          prettierd # Multi-language
          shfmt
          isort
          stylua

          # LSP
          lua-language-server
          my.logseqlsp
          nixd
          rustToolchain

          # Tools
          git
          cmake
          fzf
          gcc
          gnumake
          nodejs
          fswatch # File watcher utility, replacing libuv.fs_event for neovim 10.0
          sqlite
        ]
        ++ lib.lists.optional (! config.my.isDarwin) vscode-extensions.vadimcn.vscode-lldb.adapter;
      plugins = [
        pkgs.vimPlugins.lazy-nvim # All other plugins are managed by lazy-nvim
      ];
    };

    home.packages = lib.lists.optional config.my.roles.graphical.enable pkgs.neovide;

    xdg.configFile = {
      # Raw symlink to the plugin manager lock file, so that it stays writeable
      #"nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/lazy-lock.json";
      "nvim/lua/nix/palette.lua".text = "return ${lib.generators.toLua {} palette}";
      "nvim/lua/nix/tools.lua".text = ''
        vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.${
          if config.my.isDarwin
          then "dylib"
          else "so"
        }'

        return {
          gcc = '${lib.getExe pkgs.gcc}';
        }
      '';
      "nvim" = {
        source = ./config;
        recursive = true;
      };
      "${config.my.configDir}/.nixd.json".text = builtins.toJSON {
        options = {
          enable = true;
          target.installable = ".#homeConfigurations.nixd.options";
        };
      };
    };

    stylix.targets.vim.enable = false;

    home.activation.neovim = lib.home-manager.hm.dag.entryAfter ["linkGeneration"] ''
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
