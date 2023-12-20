{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./terminal.nix
    ./graphical.nix
    ./gaming.nix
  ];

  programs.home-manager.enable = true;

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  home.file.scripts = {
    source = ../scripts;
    recursive = true;
  };

  programs.gpg = {
    enable = true;
  };

  stylix = let
    palette = builtins.mapAttrs (name: value: builtins.substring 1 (-1) value) config.my.colors.palette;
  in {
    image = pkgs.fetchurl {
      url = "https://user-images.githubusercontent.com/4097716/247954752-8c7f3db1-e6a3-4f77-9cc4-262b3d929c36.png";
      sha256 = "sha256-O2AIOKMIgNwZ1/wEZyoVWiby6+FLrNWn9kiSw9rsOAI=";
    };
    autoEnable = true;
    polarity = config.my.colors.background;
    base16Scheme = {
      base00 = palette.base; # Default Background
      base01 = palette.subtext0; # Lighter Background (Used for status bars)
      base02 = palette.surface2; # Selection Background
      base03 = palette.overlay0; # Comments, Invisibles, Line Highlighting
      base04 = palette.base; # Dark Foreground (Used for status bars)
      base05 = palette.text; # Default Foreground, Caret, Delimiters, Operators
      base06 = palette.flamingo; # Light Foreground (Not often used)
      base07 = palette.navy; # Light Background (Not often used)
      base08 = palette.red; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
      base09 = palette.peach; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
      base0A = palette.sand; # Classes, Markup Bold, Search Text Background
      base0B = palette.green; # Strings, Inherited Class, Markup Code, Diff Inserted
      base0C = palette.teal; # Support, Regular Expressions, Escape Characters, Markup Quotes
      base0D = palette.blue; # Functions, Methods, Attribute IDs, Headings
      base0E = palette.purple; # Keywords, Storage, Selector, Markup Italic, Diff Changed
      base0F = palette.cherry; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
    };
  };
}
