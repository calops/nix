{
  lib,
  pkgs,
  ...
}: {
  nixGlWrap = {
    config,
    pkg,
  }: let
    nixGlBin =
      if config.my.roles.graphical.nvidia.enable
      then lib.getExe pkgs.nixgl.auto.nixGLNvidia
      else lib.getExe pkgs.nixgl.nixGLIntel;
  in
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "exec ${nixGlBin} $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';

  fonts = {
    iosevka-comfy = {
      name = "Iosevka Comfy";
      package = pkgs.iosevka-comfy.comfy;
    };
    luculent = {
      name = "Luculent";
      package = pkgs.luculent;
    };
    noto-serif = {
      name = "Noto Serif";
      package = pkgs.noto-fonts;
    };
    noto-sans = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
    };
    noto-emoji = {
      name = "Noto Emoji";
      package = pkgs.noto-fonts-emoji;
    };
    dina = {
      name = "Dina";
      package = pkgs.dina-font;
    };
    terminus = {
      name = "Terminus";
      package = pkgs.terminus_font;
    };
    cozette = {
      name = "Cozette";
      package = pkgs.cozette;
    };
    terminus-nerdfont = {
      name = "Terminus Nerd Font";
      package = pkgs.terminus-nerdfont;
    };
  };
}
