{
  den,
  colors,
  lib,
  ...
}:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
  palette = colors.palette.asHex;
in
mkProfileAspect "gaming" {
  includes = [
    den.aspects.programs._.discord
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

      hardware.graphics = {
        extraPackages = [ pkgs.mangohud ];
        extraPackages32 = [ pkgs.mangohud ];
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
    { pkgs, inputs', ... }:
    {
      home.packages = [
        pkgs.protonup-qt
        pkgs.lutris
        pkgs.steamcmd
        pkgs.steam-run
        pkgs.wineWow64Packages.waylandFull
        pkgs.winetricks
      ];

      programs.mangohud = {
        enable = true;
        enableSessionWide = true;
      };

      stylix.targets.mangohud.enable = false;

      xdg.configFile."MangoHud/MangoHud.conf".text = ''
        # Hidden by default
        no_display

        # Text
        font_size=14
        font_file=${inputs'.aporetic.packages.aporetic-sans-mono}/share/fonts/TTF/aporetic-sans-mono-normalregularupright.ttf
        text_outline
        text_color=${palette.text}

        # Layout
        horizontal
        hud_compact
        position=top-left
        background_color=${palette.base}
        background_alpha=0
        round_corners=0

        # Bindings
        toggle_hud=Shift_R+F12
        toggle_preset=Shift_R+F10

        # Clock
        time
        time_no_label

        # GPU
        gpu_stats
        gpu_temp
        gpu_load_change
        gpu_load_value=50,90
        gpu_load_color=${palette.text},${palette.tangerine},${palette.cherry}
        gpu_text=GPU
        gpu_color=${palette.green}

        # CPU
        cpu_stats
        cpu_temp
        cpu_load_change
        cpu_load_value=50,90
        cpu_load_color=${palette.text},${palette.tangerine},${palette.cherry}
        cpu_color=${palette.teal}
        cpu_text=CPU
        core_load_change

        # FPS
        fps
        engine_color=${palette.purple}

        # Graph
        frame_timing
        frametime_color=${palette.sand}
      '';
    };
}
