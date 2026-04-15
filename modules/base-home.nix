{ inputs, den, lib, config, perSystem, pkgs, ... }:
{
  den.aspects.base-home = {
    homeManager =
      { config, pkgs, lib, perSystem, nixosConfig ? null, darwinConfig ? null, ... }:
      {
        imports = [
          ../_common
          ../_home/programs
          inputs.stylix.homeModules.stylix
          inputs.nix-index-database.homeModules.nix-index
        ];

        options.my = {
          configDir = lib.mkOption {
            type = lib.types.path;
            default =
              nixosConfig.my.configDir or darwinConfig.my.configDir or "${config.home.homeDirectory}/nix";
          };

          configType = lib.mkOption {
            type = lib.types.str;
            default =
              if config.my.isNixos then
                "nixos"
              else if config.my.isDarwin then
                "darwin"
              else
                "standalone";
          };

          isNixos = lib.mkOption {
            type = lib.types.bool;
            default = nixosConfig != null;
            readOnly = true;
          };

          isDarwin = lib.mkOption {
            type = lib.types.bool;
            default = darwinConfig != null;
            readOnly = true;
          };
        };

        config = {
          home.stateVersion = "26.05";

          xdg.configFile."colors/palette.css".source = config.my.colors.palette.asCss;
          xdg.configFile."colors/palette.gtk.css".source = config.my.colors.palette.asGtkCss;
          xdg.configFile."colors/palette.scss".source = config.my.colors.palette.asScss;
          xdg.dataFile."lua/palette.lua".source = config.my.colors.palette.asLua;

          stylix.overlays.enable = false;

          programs.home-manager.enable = true;
          programs.gpg.enable = true;
          programs.dircolors.enable = true;

          home.packages = [
            perSystem.nix-index-database.nix-index-with-db
          ];

          nix.package = lib.mkDefault pkgs.nix;
          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };

          services.network-manager-applet.enable = !pkgs.stdenv.isDarwin;
          services.gnome-keyring.enable = !pkgs.stdenv.isDarwin;
          services.udiskie = {
            enable = !pkgs.stdenv.isDarwin;
            tray = "auto";
          };

          home.sessionVariables = {
            NH_FLAKE = config.my.configDir;
            NH_NO_CHECKS = "1";
            NIX_CONFIG_TYPE = config.my.configType;
          };

          programs.nh = lib.mkIf (config.my.configType == "standalone") {
            enable = true;
            package = perSystem.self.nh;
            flake = config.my.configDir;
          };

          xdg.enable = true;
          xdg.mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
            enable = true;
            defaultApplications =
              let
                firefox = "firefox-beta.desktop";
              in
              {
                "text/html" = firefox;
                "x-scheme-handler/http" = firefox;
                "x-scheme-handler/https" = firefox;
                "x-scheme-handler/about" = firefox;
                "x-scheme-handler/unknown" = firefox;
                "application/pdf" = "org.pwmt.zathura.desktop";
                "text/plain" = "nvim.desktop";
              };
          };

          systemd.user.targets.tray.Unit = {
            Description = "Home Manager System Tray";
            Requires = [ "graphical-session-pre.target" ];
          };
          systemd.user.services.swayidle.Unit.After = lib.mkForce [ "graphical-session.target" ];
          systemd.user.services.udiskie.Unit.After = lib.mkForce [
            "graphical-session.target"
            "tray.target"
          ];
          systemd.user.services.network-manager-applet.Unit.After = lib.mkForce [
            "graphical-session.target"
            "tray.target"
          ];
        };
      };
  };
}
