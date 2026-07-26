{
  den.aspects.programs.provides.mangohud = {
    nixos =
      { pkgs, ... }:
      {
        hardware.graphics = {
          extraPackages = [ pkgs.mangohud ];
          extraPackages32 = [ pkgs.mangohud ];
        };
      };

    homeManagerLinux =
      {
        inputs',
        colors,
        ...
      }:
      let
        palette = colors.palette.asHex;
      in
      {
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
          font_file=${inputs'.aporetic.packages.aporetic-sans-mono-prebuilt}/share/fonts/TTF/aporetic-sans-mono-normalregularupright.ttf
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
  };
}
