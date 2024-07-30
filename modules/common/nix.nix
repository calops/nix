{ pkgs, lib, ... }:
{
  nix.package = lib.mkForce pkgs.lix;
  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];

    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://calops.cachix.org"
      "https://cache.garnix.io"
    ];

    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];

    trusted-users = [
      "root"
      "@wheel"
      "@sudo"
      "@admin"
    ];
  };
}
