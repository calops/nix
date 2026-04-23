{ ... }:
{
  flake-file.inputs = {
    quickshell.url = "github:calops/quickshell?ref=fix/region-parent-tracking";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.programs.provides.quickshell =
    { host, ... }:
    {
      homeManagerLinux =
        {
          pkgs,
          config,
          lib,
          inputs',
          ...
        }:
        {
          programs.quickshell = {
            enable = true;
            activeConfig = null;
            systemd.enable = true;

            package = pkgs.symlinkJoin {
              name = "quickshell";
              paths = [ inputs'.quickshell.packages.default ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/quickshell \
                	--set QT_QPA_PLATFORMTHEME gtk3 \
                	--prefix PATH : ${
                   lib.makeBinPath [
                     pkgs.cava
                     pkgs.ddcutil
                     pkgs.anyrun-provider
                     pkgs.qt6.qtshadertools
                   ]
                 }
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
            config.lib.file.mkOutOfStoreSymlink "${host.configDir}/modules/programs/quickshell/_config";
        };
    };
}
