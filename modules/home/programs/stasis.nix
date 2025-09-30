{
  lib,
  config,
  perSystem,
  pkgs,
  inputs,
  ...
}:
{
  config = lib.mkIf config.my.roles.graphical.enable {
    home.packages = [
      perSystem.self.stasis
      pkgs.brightnessctl
    ];

    # systemd.user.services.stasis = inputs.self.lib.mkGraphicalSessionService {
    #   description = "Stasis idle manager";
    #   command = "stasis";
    # };

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

          # suspend:
          #   timeout 36000
          #   command "systemctl suspend"
          # end

          dpms:
            timeout 1800
            command "niri msg action power-off-monitors"
          end
        end
      '';
  };
}
