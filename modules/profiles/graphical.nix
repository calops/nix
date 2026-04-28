{ den, lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "graphical" {
  includes = [
    den.aspects.hmPlatforms
    den.aspects.fonts
    den.aspects.programs._.niri
    den.aspects.programs._.anyrun
    den.aspects.programs._.zed
    den.aspects.programs._.walker
    den.aspects.programs._.sable
    den.aspects.programs._.neovide
    den.aspects.programs._.mpv
    den.aspects.programs._.gtk
    den.aspects.programs._.element
    den.aspects.programs._.wezterm
    den.aspects.programs._.quickshell
    den.aspects.programs._.firefox
    den.aspects.programs._.kitty

    {
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
            # FIXME: waiting for upstream fix
            enable = false;
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
            packages = [ pkgs.terminus_font ];
            earlySetup = true;
          };
        };
    }

    {
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
            options.font = config.fonts.monospace.name;
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
    }

    {
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
    }
  ];
}
