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

        # FIXME: upstream openldap is failing so this is needed, remove when fixed
        (pkgs.lutris.override {
          # Intercept buildFHSEnv to modify target packages
          buildFHSEnv =
            args:
            pkgs.buildFHSEnv (
              args
              // {
                multiPkgs =
                  envPkgs:
                  let
                    # Fetch original package list
                    originalPkgs = args.multiPkgs envPkgs;

                    # Disable tests for openldap
                    customLdap = envPkgs.openldap.overrideAttrs (_: {
                      doCheck = false;
                    });
                  in
                  # Replace broken openldap with the custom one
                  builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
              }
            );
        })

        pkgs.steamcmd
        pkgs.steam-run
        pkgs.wineWow64Packages.waylandFull
        pkgs.winetricks
      ];

    };
}
