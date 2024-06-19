# This isn't in a flat process-compose.nix file because the automatic import from Snowfall somehow results in an
# infinite recursion. No idea why.
{
  lib,
  pkgs,
  config,
  ...
}:
let
  themeFile = "${pkgs.my.catppuccin-process-compose-theme}/catppuccin-mocha.yaml";
  configFile =
    pkgs.writeText "settings.yaml" # yaml
      ''
        theme: Custom Style
        sort:
          by: NAME
          isReversed: false
      '';
in
{
  config = lib.mkIf config.my.roles.terminal.enable (
    {
      home.packages = [ pkgs.process-compose ];
    }
    // (lib.optionalAttrs pkgs.stdenv.isLinux {
      xdg.configFile."process-compose/settings.yaml".source = configFile;
      xdg.configFile."process-compose/theme.yaml".source = themeFile;
    })
    # process-compose doesn't seem to respect XDG settings on OSX
    // (lib.optionalAttrs pkgs.stdenv.isDarwin {
      home.file."Library/Application Support/process-compose/settings.yaml".source = configFile;
      home.file."Library/Application Support/process-compose/theme.yaml".source = themeFile;
    })
  );
}
