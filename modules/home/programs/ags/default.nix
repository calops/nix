{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  system = "x86_64-linux";
  deps = with pkgs; [
    sassc
    bun
  ];
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.ags = {
      enable = true;
      configDir = null;
      package = inputs.ags.packages.${system}.agsFull.overrideAttrs {
        postFixup = ''
          wrapProgram $out/bin/ags --prefix PATH : ${lib.makeBinPath deps}
        '';
      };
      extraPackages = deps;
    };

    xdg.configFile."ags".source = config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/ags/config";
  };
}
