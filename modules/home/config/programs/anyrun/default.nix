{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  package = inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins;
  palette = config.my.colors.palette.asGtkCss;
in {
  imports = [inputs.anyrun.homeManagerModules.default];
  config = lib.mkIf (config.my.roles.graphical.enable && !config.my.isDarwin) {
    programs.anyrun = {
      enable = true;
      package = package;

      config = {
        y.fraction = 0.3;
        plugins = [
          "${package}/lib/libapplications.so"
          "${package}/lib/librink.so"
          "${package}/lib/libshell.so"
          "${package}/lib/libdictionary.so"
          "${package}/lib/libsymbols.so"
          "${package}/lib/libtranslate.so"
        ];
      };

      extraCss =
        # css
        ''
          @import url("${palette}");

          #window {
            background-color: rgba(30, 30, 46, 0.4); /* palette.base */
          }

          box#main {
            border-radius: 10px;
            background-color: @mantle;
          }

          box#plugin {
            border-radius: 10px;
            background-color: none;
          }

          box#match {
            background-color: none;
            border-radius: 10px;
          }
        '';
    };
  };
}
