{
  lib,
  config,
  ...
}:
{
  options.my.roles.ai.enable = lib.mkEnableOption "Enable AI tools";

  config = lib.mkIf config.my.roles.ai.enable {
    nix.settings = {
      extra-substituters = [
        "https://ai.cachix.org"
        "https://cuda-maintainers.cachix.org"
        "https://nix-ai-stuff.cachix.org"
      ];

      extra-trusted-public-keys = [
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "nix-ai-stuff.cachix.org-1:WlUGeVCs26w9xF0/rjyg32PujDqbVMlSHufpj1fqix8="
      ];
    };
  };
}
