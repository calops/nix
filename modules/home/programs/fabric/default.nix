{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    # home.packages = [
    #   (pkgs.python311Packages.buildPythonApplication {
    #     name = "fabric-bar";
    #     version = "0.0.1";
    #     pyproject = true;
    #
    #     src = ./pythonPackage;
    #
    #     nativeBuildInputs = [
    #       pkgs.wrapGAppsHook3
    #       pkgs.gtk3
    #       pkgs.gobject-introspection
    #       pkgs.cairo
    #     ];
    #
    #     dependencies = [
    #       (inputs.fabric.packages.${pkgs.system}.default.override { inherit pkgs; })
    #     ];
    #
    #     doCheck = false;
    #     dontWrapGApps = true;
    #
    #     preFixup = ''
    #       makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    #     '';
    #   })
    # ];
    #
    # xdg.configFile."fabric".source = config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/fabric/config";
  };
}
