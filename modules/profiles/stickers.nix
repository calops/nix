{ lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "stickers" {
  nixos = {
    programs.fuse.userAllowOther = true;
  };

  homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.rclone ];
  };

  homeManagerLinux =
    { pkgs, ... }:
    let
      gdrive-mount = pkgs.writeShellScript "rclone-gdrive-mount" ''
        set -euo pipefail

        # Get the GDrive token via op-credential (cached by default, fetches if missing)
        GDRIVE_TOKEN="$(op-credential --raw "rclone gdrive")"

        export RCLONE_CONFIG_GDRIVE_TYPE=drive
        export RCLONE_CONFIG_GDRIVE_SCOPE=drive
        export RCLONE_CONFIG_GDRIVE_TOKEN="$GDRIVE_TOKEN"

        exec ${lib.getExe pkgs.rclone} mount gdrive:Pictures/Stickers "$HOME/Pictures/Stickers" \
          --vfs-cache-mode writes \
          --dir-cache-time 30m \
          --poll-interval 30s \
          --log-level INFO
      '';
    in
    {
      systemd.user.services.rclone-gdrive = {
        Unit = {
          Description = "rclone mount for Google Drive (Stickers)";
          After = [
            "graphical-session.target"
            "network-online.target"
          ];
          Requires = [ "network-online.target" ];
        };

        Service = {
          Type = "simple";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Pictures/Stickers";
          ExecStart = "${gdrive-mount}";
          ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u %h/Pictures/Stickers";
          Restart = "on-failure";
          RestartSec = "5s";
        };

        Install.WantedBy = [ "default.target" ];
      };
    };
}
