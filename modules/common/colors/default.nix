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
      asHexWithHashtag = lib.mkOption {
        type = my.types.palette;
        description = "Color palette";
      };
      asHex = lib.mkOption {
        type = my.types.palette;
        description = "Color palette";
      };
      asHexWith0x = lib.mkOption {
        type = my.types.palette;
        description = "Color palette";
      };
      asRgbHex = lib.mkOption {
        type = my.types.palette;
        description = "Color palette in RGB format";
      };
      asRgbInt = lib.mkOption {
        type = my.types.palette;
        description = "Color palette in RGB integer format";
      };
      asRgbIntTuple = lib.mkOption {
        type = my.types.palette;
        description = "Color palette in RGB integer tuple format";
      };
      asRgbFloat = lib.mkOption {
        type = my.types.palette;
        description = "Color palette in RGB float format";
      };
      asRgbFloatTuple = lib.mkOption {
        type = my.types.palette;
        description = "Color palette in RGB float tuple format";
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
      asLua = lib.mkOption {
        type = lib.types.path;
        description = "Path to the Lua file";
      };
    };
  };

  config = {
    my.colors.palette = rec {
      asHexWithHashtag = import ./${config.my.colors.scheme}/${config.my.colors.background}.nix;
      asHex = asHexWithHashtag |> builtins.mapAttrs (name: value: builtins.substring 1 (-1) value);
      asHexWith0x = asHex |> builtins.mapAttrs (name: value: "0x${value}");

      asRgbHex =
        asHexWithHashtag
        |> builtins.mapAttrs (
          name: value: [
            (builtins.substring 1 2 value)
            (builtins.substring 3 2 value)
            (builtins.substring 5 2 value)
          ]
        );

      asRgbInt =
        asRgbHex
        |> builtins.mapAttrs (name: value: value |> builtins.map (hex: toString (lib.fromHexString hex)));

      asRgbIntTuple =
        asRgbInt |> builtins.mapAttrs (name: value: value |> (builtins.concatStringsSep ", "));

      asRgbFloat = asRgbInt |> builtins.mapAttrs (name: value: value |> builtins.map (int: int / 255.0));

      asRgbFloatTuple =
        asRgbFloat |> builtins.mapAttrs (name: value: value |> (builtins.concatStringsSep ", "));

      asCss = pkgs.writeText "colors.css" ''
        :root {
        ${lib.concatStringsSep "\n" (
          asHexWithHashtag
          |> builtins.mapAttrs (name: value: "  --palette-" + name + ": " + value + ";")
          |> builtins.attrValues
        )}
        }
      '';

      asGtkCss = pkgs.writeText "colors.gtk.css" (
        lib.concatStringsSep "\n" (
          asHexWithHashtag
          |> builtins.mapAttrs (name: value: "@define-color palette-" + name + " " + value + ";")
          |> builtins.attrValues
        )
      );

      asScss = pkgs.writeText "colors.scss" ''
        ${lib.concatStringsSep "\n" (
          asHexWithHashtag
          |> builtins.mapAttrs (name: value: "$" + name + ": " + value + ";")
          |> builtins.attrValues
        )}
      '';

      asLua = pkgs.writeText "palette.lua" ''
        return ${lib.generators.toLua { } asHexWithHashtag}
      '';
    };
  };
}
