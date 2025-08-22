{
  perSystem,
  pkgs,
  ...
}: {
  aporetic-sans = {
    name = "Aporetic Sans";
    package = perSystem.aporetic.aporetic-sans-prebuilt;
  };
  aporetic-sans-mono = {
    name = "Aporetic Sans Mono";
    package = perSystem.aporetic.aporetic-sans-mono-prebuilt;
  };
  iosevka = {
    name = "Iosevka";
    package = pkgs.iosevka;
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
  terminess = {
    name = "Terminess Nerd Font";
    package = pkgs.nerd-fonts.terminess-ttf;
  };
  nerdfont-symbols = {
    name = "Symbols Nerd Font Mono";
    package = pkgs.nerd-fonts.symbols-only;
  };
}
