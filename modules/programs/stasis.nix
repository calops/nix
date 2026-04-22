{ ... }:
{
  flake-file.inputs = {
    stasis.url = "github:saltnpepper97/stasis";
    stasis.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.programs.stasis = {
    homeManagerLinux =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          inputs'.stasis.packages.stasis
          pkgs.brightnessctl
        ];

        xdg.configFile."stasis/config.rune".text = # runescript
          ''
            app_default_timeout 900

            idle:
              resume_command "systemctl resume-sessions"
              pre_suspend_command "notify-send 'System suspending in 5 seconds' && sleep 5"
              monitor_media true
              respect_idle_inhibitors true

              inhibit_apps [
                "vlc"
                "mpv"
                r".*\.exe"
                r"steam_app_.*"
                r"firefox.*"
              ]

              lock_screen:
                timeout = 900
                command "swaylock"
              end

              dpms:
                timeout 1800
                command "niri msg action power-off-monitors"
              end
            end
          '';
      };
  };
}
