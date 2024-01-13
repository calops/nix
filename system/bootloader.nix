{pkgs, ...}: {
  boot = {
    loader.efi.canTouchEfiVariables = true;

    loader.grub = {
      enable = true;
      efiSupport = true;
      useOSProber = false; # auto-detect other OSes
      device = "nodev"; # install in /boot for EFI
      theme = pkgs.stdenv.mkDerivation {
        name = "catppuccin-mocha-grub-theme";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "grub";
          rev = "803c5df0e83aba61668777bb96d90ab8f6847106";
          hash = "sha256-/bSolCta8GCZ4lP0u5NVqYQ9Y3ZooYCNdTwORNvR7M0=";
        };
        installPhase = ''
          mkdir -p $out/
          cp -r src/catppuccin-mocha-grub-theme/* $out
        '';
      };
    };
  };

  stylix.targets.grub.enable = false;
}
