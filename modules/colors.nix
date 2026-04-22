{ den, lib, ... }:
let
  colors.background = "dark";
  colors.palette = rec {
    # TODO: this should be in its own file somewhere, and configurable
    asHexWithHashtag = {
      lime = "#d8f7a6";
      green = "#a6e3a1";
      forest = "#6ac26a";

      mint = "#a6f7e3";
      teal = "#7ad5d5";
      turquoise = "#5aa6a6";

      sky = "#a6d8f7";
      blue = "#89b4fa";
      navy = "#6c7fde";

      mauve = "#cba6f7";
      purple = "#b48bf2";
      violet = "#8b6af2";

      pink = "#f7a6c2";
      red = "#f38ba8";
      cherry = "#f26d85";

      orange = "#f7c6a6";
      peach = "#f2b48b";
      tangerine = "#f2a66d";

      yellow = "#f7e3a6";
      sand = "#f2d48b";
      gold = "#f2c46d";

      rosewater = "#f5e0dc";
      flamingo = "#f2cdcd";
      coral = "#f2b7b7";

      text = "#cdd6f4";
      subtext1 = "#bac2de";
      subtext0 = "#a6adc8";

      overlay2 = "#9399b2";
      overlay1 = "#7f849c";
      overlay0 = "#6c7086";

      surface2 = "#585b70";
      surface1 = "#45475a";
      surface0 = "#313244";

      base = "#1e1e2e";
      mantle = "#181825";
      crust = "#11111b";
    };

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
      asRgbHex |> builtins.mapAttrs (name: value: value |> map (hex: lib.fromHexString hex));

    asRgbIntTuple =
      asRgbInt |> builtins.mapAttrs (name: value: value |> map (i: toString i) |> (builtins.concatStringsSep ", "));

    asRgbFloat = asRgbInt |> builtins.mapAttrs (name: value: value |> map (int: int / 255.0));

    asRgbFloatTuple =
      asRgbFloat |> builtins.mapAttrs (name: value: value |> map (f: toString f) |> (builtins.concatStringsSep ", "));

    asCss = ''
      :root {
      ${lib.concatStringsSep "\n" (
        asHexWithHashtag
        |> builtins.mapAttrs (name: value: "  --palette-" + name + ": " + value + ";")
        |> builtins.attrValues
      )}
      }
    '';

    asGtkCss = (
      lib.concatStringsSep "\n" (
        asHexWithHashtag
        |> builtins.mapAttrs (name: value: "@define-color palette-" + name + " " + value + ";")
        |> builtins.attrValues
      )
    );

    asScss = ''
      ${lib.concatStringsSep "\n" (
        asHexWithHashtag
        |> builtins.mapAttrs (name: value: "$" + name + ": " + value + ";")
        |> builtins.attrValues
      )}
    '';

    asLua = ''
      return ${lib.generators.toLua { } asHexWithHashtag}
    '';
  };
in
{
  den.aspects.colors = {
    nixos._module.args.colors = colors;
    darwin._module.args.colors = colors;
    homeManager._module.args.colors = colors;

    includes = [
      (
        { user, ... }:
        {
          homeManager.xdg = {
            dataFile."colors/palette.css".text = user.my.colors.palette.asCss;
            dataFile."colors/palette.gtk.css".text = user.my.colors.palette.asGtkCss;
            dataFile."colors/palette.scss".text = user.my.colors.palette.asScss;
            dataFile."lua/palette.lua".text = user.my.colors.palette.asLua;
          };
        }
      )
    ];
  };

  den.default.includes = [ den.aspects.colors ];
}
