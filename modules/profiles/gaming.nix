{
  den,
  lib,
  ...
}:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "gaming" {
  includes = [
    den.aspects.programs._.discord
    den.aspects.programs._.mangohud
  ];

  nixos =
    { pkgs, lib, ... }:
    {
      programs.gamemode.enable = true;
      programs.coolercontrol.enable = true;

      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      programs.gamescope = {
        enable = true;
        capSysNice = true;
        args = [
          "--hdr-enabled"
          "--hdr-itm-enable"
          "--hide-cursor-delay=3000"
          "--fade-out-duration=200"
          "--xwayland-count=2"
        ];
      };

      hardware.xpadneo.enable = true;

      environment.systemPackages = [
        pkgs.protontricks
        pkgs.i2c-tools
      ];

      services.hardware.openrgb = {
        enable = true;
        motherboard = lib.mkDefault "intel";
      };
    };

  homeManagerLinux =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.protonup-qt

        pkgs.lutris
        pkgs.steamcmd
        pkgs.steam-run
        pkgs.wineWow64Packages.waylandFull
        pkgs.winetricks

        # Wrapper: launch a game with XWayland XKB forced to US QWERTY,
        # then restore the original layout after exit.
        # Usage: qwerty-game <command>
        (pkgs.writeShellScriptBin "qwerty-game" ''
          # Save original XWayland XKB state
          SAVE_LAYOUT=$(setxkbmap -query | grep 'layout:' | awk '{print $2}')
          SAVE_OPTIONS=$(setxkbmap -query | grep 'options:' | sed 's/^[[:space:]]*options:[[:space:]]*//')

          # Switch XWayland to US QWERTY
          setxkbmap us

          # Run the game
          "$@"
          RET=$?

          # Restore original layout
          if [ -n "$SAVE_OPTIONS" ]; then
            setxkbmap -layout "$SAVE_LAYOUT" -option "$SAVE_OPTIONS"
          else
            setxkbmap -layout "$SAVE_LAYOUT"
          fi

          exit $RET
        '')
      ];

    };
}
