{ den, lib, ... }:
{
  den.default.defineOptions.profiles.graphical.enable = lib.mkEnableOption "Graphical";

  den.aspects.graphical = {
    setOptions.profiles.graphical.enable = true;

    includes = [
      den.aspects.fonts
      den.aspects.programs.niri
      den.aspects.programs.anyrun
      den.aspects.programs.zed
      den.aspects.programs.walker
      den.aspects.programs.sable
      den.aspects.programs.neovide
      den.aspects.programs.mpv
      den.aspects.programs.gtk
      den.aspects.programs.element
      den.aspects.programs.wezterm
      den.aspects.programs.quickshell
      den.aspects.programs.firefox
      den.aspects.programs.kitty
    ];

    nixos =
      { pkgs, lib, ... }:
      {
        environment.sessionVariables = {
          WLR_NO_HARDWARE_CURSORS = "1";
          NIXOS_OZONE_WL = "1";
        };

        security.soteria.enable = true;

        services = {
          xserver.enable = true;
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;
        };

        hardware.graphics.enable = true;
        security.pam.services.swaylock = { };

        services.kmscon = {
          enable = true;
          hwRender = true;
          useXkbConfig = true;
          fonts = [
            {
              name = "Terminess Nerd Font";
              package = pkgs.nerd-fonts.terminess-ttf;
            }
          ];
        };

        console = {
          font = "ter-124b";
          keyMap = lib.mkDefault "fr";
          packages = [ pkgs.terminus ];
          earlySetup = true;
        };
      };

    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        home.packages = [
          pkgs.libnotify
          pkgs.slack
        ];

        programs.zathura = {
          enable = true;
          options.font = config.stylix.fonts.monospace.name;
        };

        stylix = {
          cursor = {
            name = "catppuccin-mocha-peach-cursors";
            size = 32;
            package = pkgs.catppuccin-cursors;
          };
        };

        xdg.mimeApps = {
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

    homeManagerLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.google-chrome
          pkgs.waypipe
          pkgs.wl-clipboard
        ];

        services.clipman.enable = true;
      };
  };
}
