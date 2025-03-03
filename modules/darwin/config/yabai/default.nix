{ ... }:
{
  services.yabai = {
    enable = false;

    config = {
      debug_output = true;
      auto_balance = true;
      layout = "bsp";
      focus_follows_mouse = "autoraise";

      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };

    extraConfig = # sh
      ''
        yabai -m rule --add app='kunkun' manage=off
      '';
  };
}
