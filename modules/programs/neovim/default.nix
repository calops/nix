{ ... }:
{
  flake-file.inputs = {
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.programs.neovim = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        inputs',
        ...
      }:
      let
        nvimDir = "${config.my.configDir}/modules/home/programs/neovim";

        rustToolchain = inputs'.fenix.packages.complete.withComponents [
          "cargo"
          "clippy"
          "rust-src"
          "rustc"
          "rustfmt"
          "rust-analyzer"
        ];
      in
      {
        home.sessionVariables = {
          EDITOR = "nvim";
          MANPAGER = "nvim +Man!";
        };

        programs.neovim = {
          enable = true;
          defaultEditor = true;
          package = inputs'.neovim-nightly.packages.neovim;
          extraPackages = [
            pkgs.prettierd
            pkgs.shfmt
            pkgs.isort
            pkgs.sqlfluff
            pkgs.stylua

            pkgs.lua-language-server
            pkgs.nixd
            pkgs.nil
            pkgs.vtsls
            pkgs.fish-lsp
            pkgs.kdePackages.qtdeclarative
            pkgs.vscode-json-languageserver
            rustToolchain

            pkgs.cmake
            pkgs.fswatch
            pkgs.fzf
            pkgs.gcc
            pkgs.git
            pkgs.gnumake
            pkgs.nodejs
            pkgs.sqlite
            pkgs.tree-sitter
            pkgs.luarocks
            pkgs.luajit
            pkgs.hub
            pkgs.wget
            pkgs.pandoc
            pkgs.imagemagick
            pkgs.mermaid-cli
            pkgs.github-mcp-server
            pkgs.ghostscript
          ];
        };

        xdg.dataFile = {
          "nvim/nix/nix.lua".text = ''
            vim.g.is_nix = true
            vim.g.font_name = '${config.my.roles.graphical.fonts.monospace.name}'
            vim.g.gcc_bin_path = '${lib.getExe pkgs.gcc}'
            vim.g.codeium_language_server_path = '${lib.getExe' pkgs.codeium "codeium_language_server"}'
            vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.${
              if pkgs.stdenv.isDarwin then "dylib" else "so"
            }'
          '';
        };

        xdg.configFile = {
          "nvim/init.lua".enable = false;
          "nvim".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/_config";
        };

        home.file."${config.my.configDir}/.nvim.lua".text =
          let
            flake = ''builtins.getFlake "${config.my.configDir}"'';
          in
          ''
            vim.g.lazydev_enabled = true

            vim.lsp.config("nixd", {
              settings = {
                nixd = {
                  nixpkgs = { expr = { 'import (${flake}).inputs.nixpkgs {}' } },
                  options = {
                    nixos = { expr = { '(${flake}).nixosConfigurations.tocardstation.options' } },
                    homeManager = { expr = { '(${flake}).homeConfigurations.tocardstation.options' }, },
                    darwin = { expr = { '(${flake}).darwinConfigurations.remilabeyrie-kiro.options' }, },
                  }
                },
              }
            })
          ''
          + lib.optionalString pkgs.stdenv.isLinux ''
            vim.lsp.config("qmlls", {
              cmd = {
                "qmlls",
                "-I", "${config.programs.quickshell.package}/lib/qt-6/qml",
                "-I", "${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml",
              },
            })
          '';

        stylix.targets.neovim.enable = false;

        home.activation.neovim = inputs'.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          LOCK_FILE=$(readlink -f ~/.config/nvim/lazy-lock.json)
          [ ! -f "$LOCK_FILE" ] && echo "No lock file found, skipping" && exit 0

          STATE_DIR=~/.local/state/nix/
          STATE_FILE=$STATE_DIR/lazy-lock-checksum

          [ ! -d $STATE_DIR ] && mkdir -p $STATE_DIR
          [ ! -f $STATE_FILE ] && touch $STATE_FILE

          HASH=$(nix hash path $LOCK_FILE)

          if [ "$(cat $STATE_FILE)" != "$HASH" ]; then
            echo "Syncing neovim plugins"
            $DRY_RUN_CMD ${config.programs.neovim.finalPackage}/bin/nvim --headless "+Lazy! restore" +qa
            $DRY_RUN_CMD echo $HASH >$STATE_FILE
          else
            $VERBOSE_ECHO "Neovim plugins already synced, skipping"
          fi
        '';
      };
  };
}
