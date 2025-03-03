{
  config,
  lib,
  pkgs,
  ...
}:
let
  nvimDir = "${config.my.configDir}/modules/home/programs/neovim";

  rustToolchain = pkgs.fenix.complete.withComponents [
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
    # TODO: figure out why this is needed
    home.sessionVariables.EDITOR = "nvim";

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = pkgs.nightly.neovim;
      extraPackages = [
        # Formatters
        pkgs.nixfmt-rfc-style # Nix
        pkgs.prettierd # Multi-language
        pkgs.shfmt # Shell
        pkgs.isort # Python
        pkgs.stylua # Lua
        pkgs.sqlfluff

        # LSP
        pkgs.lua-language-server # lua
        pkgs.my.logseqlsp # logseq
        pkgs.nightly.nixd # nix
        pkgs.nil # nix
        pkgs.ruff # python
        pkgs.pyright # python
        pkgs.vtsls # typescript / javascript
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
        pkgs.hub
        pkgs.wget # for mason.nvim
        pkgs.pandoc # for devdocs.nvim
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
          vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.${
            if pkgs.stdenv.isDarwin then "dylib" else "so"
          }'
        '';
    };

    xdg.configFile = {
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/config";
    };

    # Nixd LSP configuration
    home.file."${config.my.configDir}/.neoconf.json".text =
      let
        flake = ''builtins.getFlake "${config.my.configDir}"'';
      in
      builtins.toJSON {
        lspconfig.nixd.nixd = {
          nixpkgs.expr = ''import (${flake}).inputs.nixpkgs {}'';
          options = {
            nixos.expr = ''(${flake}).nixosConfigurations.tocardstation.options'';
            homeManager.expr = ''(${flake}).homeConfigurations."calops@tocardstation".options'';
            darwin.expr = ''(${flake}).darwinConfigurations.rlabeyrie-sonio.options'';
          };
        };
      };

    stylix.targets.neovim.enable = false;

    home.activation.neovim =
      lib.home-manager.hm.dag.entryAfter [ "linkGeneration" ] # bash
        ''
          LOCK_FILE=$(readlink -f ~/.config/nvim/lazy-lock.json)
          echo $LOCK_FILE
          [ ! -f "$LOCK_FILE" ] && echo "No lock file found, skipping" && exit 0

          STATE_DIR=~/.local/state/nix/
          STATE_FILE=$STATE_DIR/lazy-lock-checksum

          [ ! -d $STATE_DIR ] && mkdir -p $STATE_DIR
          [ ! -f $STATE_FILE ] && touch $STATE_FILE

          HASH=$(nix-hash --flat $LOCK_FILE)

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
