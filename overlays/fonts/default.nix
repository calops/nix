{
  inputs,
  ...
}:
self: super: {
  fonts = {
    aporetic-sans = {
      name = "Aporetic Sans";
      package = inputs.aporetic.packages.${super.system}.aporetic-sans-prebuilt;
    };
    aporetic-sans-mono = {
      name = "Aporetic Sans Mono";
      package = inputs.aporetic.packages.${super.system}.aporetic-sans-mono-prebuilt;
    };
    iosevka = {
      name = "Iosevka";
      package = super.iosevka;
    };
    noto-serif = {
      name = "Noto Serif";
      package = super.noto-fonts;
    };
    noto-sans = {
      name = "Noto Sans";
      package = super.noto-fonts;
    };
    noto-emoji = {
      name = "Noto Emoji";
      package = super.noto-fonts-emoji;
    };
    dina = {
      name = "Dina";
      package = super.dina-font;
    };
    terminus = {
      name = "Terminus";
      package = super.terminus_font;
    };
    cozette = {
      name = "Cozette";
      package = super.cozette;
    };
    terminess = {
      name = "Terminess Nerd Font";
      package = super.nerd-fonts.terminess-ttf;
    };
    nerdfont-symbols = {
      name = "Symbols Nerd Font Mono";
      package = super.nerd-fonts.symbols-only;
    };
  };
}
