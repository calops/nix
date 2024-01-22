pkgs: {
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
  nerdfont-symbols = {
    name = "Nerd Font Symbols";
    package = pkgs.nerdfonts.override {
      fonts = ["NerdFontsSymbolsOnly"];
    };
  };
}
