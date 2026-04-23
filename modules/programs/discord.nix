{ inputs, ... }:
{
  flake-file.inputs = {
    nixcord.url = "github:kaylorben/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.programs.provides.discord = {
    homeManager = {
      imports = [
        inputs.nixcord.homeModules.nixcord
      ];

      programs.nixcord = {
        enable = true;
        vesktop.enable = true;
        config = {
          themeLinks = [ "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css" ];
          frameless = true;
          plugins = {
            alwaysAnimate.enable = true;
            alwaysTrust.enable = true;
            fakeNitro.enable = true;
          };
        };
      };
    };
  };
}
