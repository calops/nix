{
  config,
  lib,
  pkgs,
  perSystem,
  inputs,
  ...
}:
let
  nvimDir = "${config.my.configDir}/modules/home/programs/neovim";

  rustToolchain = perSystem.fenix.complete.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
    "rust-analyzer"
  ];
in
{
  config = lib.mkIf config.my.roles.terminal.enable {
    home.sessionVariables = {
      # TODO: figure out why this is needed
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = perSystem.self.neovim;
      extraPackages = [
        # Formatters
        pkgs.prettierd # Multi-language
        pkgs.shfmt # Shell
        pkgs.isort # Python
        pkgs.sqlfluff
        pkgs.stylua
        pkgs.copilot-language-server

        # LSP
        pkgs.lua-language-server # lua
        pkgs.nixd # nix
        pkgs.nil # nix
        pkgs.vtsls # typescript / javascript
        pkgs.fish-lsp
        pkgs.kdePackages.qtdeclarative # for qmlls
        rustToolchain # rust

        # Tools
        pkgs.cmake
        pkgs.fswatch # File watcher utility, replacing libuv.fs_event for neovim 10.0
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
        pkgs.wget # for mason.nvim
        pkgs.pandoc # for devdocs.nvim
        pkgs.imagemagick
        pkgs.mermaid-cli
        pkgs.github-mcp-server
        pkgs.ghostscript
      ];

      plugins = [
        pkgs.vimPlugins.lazy-nvim # All other plugins are managed by lazy-nvim
      ];
    };

    xdg.dataFile = {
      "nvim/nix/nix.lua".text = # lua
        ''
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
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/config";
    };

    home.file."${config.my.configDir}/.nvim.lua".text =
      let
        flake = ''builtins.getFlake "${config.my.configDir}"'';
      in
      # lua
      ''
        vim.g.lazydev_enabled = true

        vim.lsp.config("nixd", {
          settings = {
            nixd = {
              nixpkgs = { expr = { 'import (${flake}).inputs.nixpkgs {}' } },
              formatting = { command = { '${lib.getExe pkgs.nixfmt-rfc-style}' } },
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

    home.activation.neovim =
      inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] # bash
        ''
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
}
