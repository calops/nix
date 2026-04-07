{
  pkgs,
  config,
  lib,
  perSystem,
  ...
}:
{
  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.quickshell = {
      enable = true;
      activeConfig = null;
      systemd.enable = true;

      package = pkgs.symlinkJoin {
        name = "quickshell";
        paths = [ perSystem.quickshell.default ];
        nativeBuildInputs = [
          pkgs.makeWrapper
        ];
        postBuild = ''
          wrapProgram $out/bin/quickshell \
            --set QT_QPA_PLATFORMTHEME gtk3 \
            --prefix PATH : ${lib.makeBinPath [ pkgs.cava pkgs.ddcutil pkgs.anyrun-provider pkgs.qt6.qtshadertools ]}
        '';

        meta.mainProgram = "quickshell";
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "shell" ''
        exec quickshell ipc call actions "$@"
      '')
    ];

    home.file."Pictures/Wallpapers/main.png".source = config.stylix.image;

    xdg.configFile."quickshell".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/quickshell/config";
  };
}
