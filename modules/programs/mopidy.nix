{ ... }:
{
  den.aspects.programs.provides.mopidy = {
    homeManager =
      { pkgs, ... }:
      {
        services.mopidy = {
          enable = true;
          extensionPackages = with pkgs; [
            mopidy-mpris
            mopidy-ytmusic
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
  };
}
