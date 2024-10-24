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
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      extraPackages = [
        # Formatters
        pkgs.nixfmt-rfc-style # Nix
        pkgs.black # Python
        pkgs.prettierd # Multi-language
        pkgs.shfmt # Shell
        pkgs.isort # Python
        pkgs.stylua # Lua

        # LSP
        pkgs.lua-language-server
        pkgs.my.logseqlsp
        pkgs.nixd
        pkgs.nil
        rustToolchain

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
      ] ++ lib.lists.optional (!pkgs.stdenv.isDarwin) pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
      plugins = [
        pkgs.vimPlugins.lazy-nvim # All other plugins are managed by lazy-nvim
      ];
    };

    xdg.configFile = {
      # Raw symlink to the plugin manager lock file, so that it stays writeable
      "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/lazy-lock.json";
      "nvim/neoconf.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/neoconf.json";

      "nvim/init.lua".text = # lua
        ''
          package.path = package.path .. ";${config.home.homeDirectory}/.config/nvim/nix/?.lua"

          vim.g.gcc_bin_path = '${lib.getExe pkgs.gcc}'
          vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.${
            if pkgs.stdenv.isDarwin then "dylib" else "so"
          }'

          require("config")
        '';

      "nvim/nix/palette.lua".text = ''return ${lib.my.asLua config.my.colors.palette.withHashtag}'';

      # Out of store symlink of whe whole configuration, for more agility when editing it
      "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/config/lua";

      # Nixd LSP configuration
      "${config.my.configDir}/.neoconf.json".text =
        let
          flake = ''builtins.getFlake "${config.my.configDir}"'';
        in
        builtins.toJSON {
          lspconfig.nixd.nixd = {
            nixpkgs.expr = ''import (${flake}).inputs.nixpkgs {}'';
            options = {
              nixos.expr = ''(${flake}).nixosConfigurations.tocardstation.options'';
              homeManager.expr = ''(${flake}).homeConfigurations."calops@tocardstation".options'';
            };
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
