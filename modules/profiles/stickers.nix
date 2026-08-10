{ den, lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "stickers" {
  includes = [
    den.aspects.programs._.onepassword
  ];

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

        GDRIVE_TOKEN="$(op-credential --raw "Stickers Gdrive API token")"
        GDRIVE_CLIENT_ID="$(op-credential --raw --field username "Stickers Gdrive API client")"
        GDRIVE_CLIENT_SECRET="$(op-credential --raw "Stickers Gdrive API client")"

        export RCLONE_CONFIG_GDRIVE_TYPE=drive
        export RCLONE_CONFIG_GDRIVE_SCOPE=drive
        export RCLONE_CONFIG_GDRIVE_TOKEN="$GDRIVE_TOKEN"
        export RCLONE_CONFIG_GDRIVE_CLIENT_ID="$GDRIVE_CLIENT_ID"
        export RCLONE_CONFIG_GDRIVE_CLIENT_SECRET="$GDRIVE_CLIENT_SECRET"

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
          After = [ "graphical-session.target" ];
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
