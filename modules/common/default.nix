{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./colors
    ./nix.nix
  ];

  config = {
    stylix =
      let
        palette = config.my.colors.palette.asHex;
      in
      {
        enable = true;
        image = pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/d6/wallhaven-d6j79o.png";
          hash = "sha256-4nFo0PPlESqoFWZhEtA9JvFnOChOIxxcZq/FqiYNfCw=";
        };
        autoEnable = true;
        polarity = config.my.colors.background;
        # mkForce required when using both NixOS and Home Manager
        base16Scheme = lib.mkForce {
          base00 = palette.base; # Default Background
          base01 = palette.surface0; # Lighter Background (Used for status bars)
          base02 = palette.surface1; # Selection Background
          base03 = palette.overlay0; # Comments, Invisibles, Line Highlighting
          base04 = palette.subtext0; # Dark Foreground (Used for status bars)
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
  };
}
