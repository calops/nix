{ ... }:
{
  flake-file.inputs = {
    aporetic.url = "github:calops/iosevka-aporetic";
    aporetic.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.fonts = {
    homeManager =
      { inputs', pkgs, ... }:
      {
        fonts.fontconfig.enable = true;

        home.packages = [
          inputs'.aporetic.packages.aporetic-sans-prebuilt
          inputs'.aporetic.packages.aporetic-sans-mono-prebuilt
        ];

        stylix = {
          fonts = {
            sizes = {
              terminal = {
                name = "Aporetic Sans Mono";
                package = inputs'.aporetic.packages.aporetic-sans-mono-prebuilt;
              };
              applications = {
                name = "Noto Sans";
                package = pkgs.noto-fonts;
              };
            };
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
          };
        };
      };
  };
}
