{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      # displayManager.sddm = {
      #   enable = true;
      #   theme = "catppuccin-mocha";
      # };
    };

    environment.systemPackages = [
      (pkgs.stdenv.mkDerivation {
        name = "catppuccin-mocha-sddm-theme";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "sddm";
          rev = "95bfcba80a3b0cb5d9a6fad422a28f11a5064991";
          hash = "sha256-Jf4xfgJEzLM7WiVsERVkj5k80Fhh1edUl6zsSBbQi6Y=";
        };
        installPhase = ''
          OUT=$out/share/sddm/themes/
          mkdir -p $OUT
          cp -r src/catppuccin-mocha $OUT
        '';
      })
    ];
  };
}
