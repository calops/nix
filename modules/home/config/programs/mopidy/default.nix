{
  lib,
  pkgs,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.audio.enable {
    services.mopidy = {
      enable = true;
      extensionPackages = with pkgs;
        [
          mopidy-mpris
          mopidy-ytmusic
        ]
        ++ lib.lists.optionals config.my.roles.graphical.enable [
          mopidy-iris
          mopidy-notify
        ];
      settings = {
        notify.enabled = true;
        ytmusic = {
          enabled = true;
          oauth_json = "~/.secrets/mopidy/ytmusic/oauth.json";
        };
      };
    };
  };
}
