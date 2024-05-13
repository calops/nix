{ ... }:
{
  services.yabai = {
    enable = true;
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
  };
}
