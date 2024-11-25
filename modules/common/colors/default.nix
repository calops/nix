{
  lib,
  config,
  pkgs,
  ...
}:
let
  mkColorOption =
    name:
    lib.mkOption {
      type = lib.types.str;
      description = "Color for " + name + " hue";
    };

  hues = lib.attrsets.genAttrs [
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

  my.types = {
    palette = lib.types.submodule { options = hues; };
  };
in
{
  options.my.colors = {
    scheme = lib.mkOption {
      type = lib.types.enum [ "radiant" ];
      default = "radiant";
      description = "Colorscheme for relevant apps";
    };

    background = lib.mkOption {
      type = lib.types.enum [
        "light"
        "dark"
      ];
      default = "dark";
      description = "Background color";
    };

    palette = {
      withHashtag = lib.mkOption {
        type = my.types.palette;
        description = "Color palette";
      };
      withoutHashtag = lib.mkOption {
        type = my.types.palette;
        description = "Color palette";
      };
      with0x = lib.mkOption {
        type = my.types.palette;
        description = "Color palette";
      };
      asCss = lib.mkOption {
        type = lib.types.path;
        description = "Path to the CSS file";
      };
      asGtkCss = lib.mkOption {
        type = lib.types.path;
        description = "Path to the GTK CSS file";
      };
      asScss = lib.mkOption {
        type = lib.types.path;
        description = "Path to the SCSS file";
      };
    };
  };

  config = {
    my.colors.palette = rec {
      withHashtag = import ./${config.my.colors.scheme}/${config.my.colors.background}.nix;
      withoutHashtag = builtins.mapAttrs (name: value: builtins.substring 1 (-1) value) withHashtag;
      with0x = builtins.mapAttrs (name: value: "0x${value}") withoutHashtag;

      asCss = pkgs.writeText "colors.css" ''
        :root {
          ${
            lib.concatStringsSep "\n" (
              builtins.attrValues (
                builtins.mapAttrs (name: value: "  --" + name + ": " + value + ";") withHashtag
              )
            )
          }
        }
      '';

      asGtkCss = pkgs.writeText "colors.gtk.css" (
        lib.concatStringsSep "\n" (
          builtins.attrValues (
            builtins.mapAttrs (name: value: "@define-color palette-" + name + " " + value + ";") withHashtag
          )
        )
      );

      asScss = pkgs.writeText "colors.scss" ''
        ${lib.concatStringsSep "\n" (
          builtins.attrValues (builtins.mapAttrs (name: value: "$" + name + ": " + value + ";") withHashtag)
        )}
      '';
    };
  };
}
