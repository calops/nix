{
  config,
  lib,
  pkgs,
  configurationName,
  ...
}: let
  cfg = config.my.roles.terminal;
  palette = config.my.colors.palette;
  nvimDir = "${config.home.homeDirectory}/.config/home-manager/roles/terminal/neovim";
  # We want gcc to override the system's one or treesitter throws a fit
  my.neovim = pkgs.neovim-nightly.overrideAttrs (attrs: {
    disallowedReferences = [];
    nativeBuildInputs = attrs.nativeBuildInputs ++ [pkgs.makeWrapper];
    postFixup = ''
      wrapProgram $out/bin/nvim --prefix PATH : ${lib.makeBinPath [pkgs.gcc]}
    '';
  });
in
  with lib; {
    config = mkIf cfg.enable {
      programs.neovim = {
        enable = true;
        package = my.neovim;
        defaultEditor = true;
        extraPackages = with pkgs; [
          fzf
          alejandra
          stylua
          nixd
          sqlfluff
          nodePackages.prettier
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
    };
  }
