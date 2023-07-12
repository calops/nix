{
  lib,
  config,
  ...
}: let
  mkColorOption = name:
    lib.mkOption {
      type = lib.types.str;
      description = "Color for " + name + " hue";
    };
  my.types = {
    palette = lib.types.submodule {
      options = lib.attrsets.genAttrs [
        "lime"
        "green"
        "forest"
        "mint"
        "teal"
        "turquoise"
        "sky"
        "blue"
        "navy"
        "mauve"
        "purple"
        "violet"
        "pink"
        "red"
        "cherry"
        "orange"
        "peach"
        "tangerine"
        "yellow"
        "sand"
        "gold"
        "rosewater"
        "flamingo"
        "coral"
        "text"
        "subtext1"
        "subtext0"
        "overlay2"
        "overlay1"
        "overlay0"
        "surface2"
        "surface1"
        "surface0"
        "base"
        "mantle"
        "crust"
      ] (name: mkColorOption name);
    };
  };
in
  with lib; {
    options = {
      my.colors = {
        scheme = mkOption {
          type = types.enum ["radiant"];
          default = "radiant";
          description = "Colorscheme for relevant apps";
        };
        background = mkOption {
          type = types.enum ["light" "dark"];
          default = "dark";
          description = "Background color";
        };
        palette = mkOption {
          type = my.types.palette;
          description = "Color palette";
        };
      };
    };
    config = {
      my.colors.palette =
        import ./${config.my.colors.scheme}/${config.my.colors.background}.nix;
    };
  }
