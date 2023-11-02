{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = "catppuccin";
        pager = "--RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
        style = "plain";
        color = "always";
        italic-text = "always";
      };
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
      themes = {
        catppuccin = {
          src =
            pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "bat";
              rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
              sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
            };
          file = "/Catppuccin-mocha.tmTheme";
        };
      };
    };
    stylix.targets.bat.enable = false;
  };
}
