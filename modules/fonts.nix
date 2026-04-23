{ ... }:
{
  flake-file.inputs = {
    aporetic.url = "github:calops/iosevka-aporetic";
    aporetic.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.fonts = {
    homeManager =
      {
        inputs',
        pkgs,
        lib,
        config,
        ...
      }:
      let
        fontType = lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
            };
            package = lib.mkOption {
              type = lib.types.package;
            };
          };
        };
      in
      {
        options.fonts = {
          monospace = lib.mkOption { type = fontType; };
          sansSerif = lib.mkOption { type = fontType; };
          serif = lib.mkOption { type = fontType; };
          emoji = lib.mkOption { type = fontType; };
          symbols = lib.mkOption { type = fontType; };
          sizes = {
            terminal = lib.mkOption {
              type = lib.types.number;
              default = 10;
            };
            applications = lib.mkOption {
              type = lib.types.number;
              default = 10;
            };
          };
        };

        config = {
          fonts = {
            serif = {
              name = "Noto Serif";
              package = pkgs.noto-fonts;
            };
            sansSerif = {
              name = "Noto Sans";
              package = pkgs.noto-fonts;
            };
            monospace = {
              name = "Aporetic Sans Mono";
              package = inputs'.aporetic.packages.aporetic-sans-mono-prebuilt;
            };
            emoji = {
              name = "Noto Emoji";
              package = pkgs.noto-fonts-color-emoji;
            };
            symbols = {
              name = "Symbols Nerd Font";
              package = pkgs.nerd-fonts.symbols-only;
            };
          };

          fonts.fontconfig.enable = true;

          home.packages = [
            inputs'.aporetic.packages.aporetic-sans-prebuilt
            inputs'.aporetic.packages.aporetic-sans-mono-prebuilt
            config.fonts.symbols.package
          ];

          stylix.fonts = {
            inherit (config.fonts)
              sizes
              serif
              sansSerif
              monospace
              emoji
              ;
          };
        };
      };
  };
}
