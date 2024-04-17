# bar=(
#   height=44
#   color=$BAR_COLOR
#   shadow=on
#   position=top
#   sticky=on
#   padding_right=10
#   padding_left=10
#   corner_radius=10
#   y_offset=-10
#   margin=10
#   blur_radius=20
#   notch_width=0
# )
{pkgs, ...}: {
  services.sketchybar = {
    enable = false;
    extraPackages = [pkgs.my.sbarlua];
  };

  environment.systemPackages = [pkgs.sketchybar-app-font];
}
