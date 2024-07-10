{ pkgs, lib, ... }:
{
  nix.package = lib.mkForce pkgs.nixVersions.latest;
  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];

    extra-substituters = [
      "https://ai.cachix.org"
      "https://cache.nixos.org"
      "https://cuda-maintainers.cachix.org"
      "https://nix-ai-stuff.cachix.org"
      "https://nix-gaming.cachix.org"
    ];

    extra-trusted-public-keys = [
      "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-ai-stuff.cachix.org-1:WlUGeVCs26w9xF0/rjyg32PujDqbVMlSHufpj1fqix8="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];

    trusted-users = [
      "root"
      "@wheel"
      "@sudo"
      "@admin"
    ];
  };
}
