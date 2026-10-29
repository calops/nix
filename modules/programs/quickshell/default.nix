{ lib, ... }:
{
  flake-file.inputs = {
    quickshell.url = "github:calops/quickshell?ref=feat/region-dynamic-items";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.programs.provides.quickshell =
    { host, ... }:
    {
      homeManager.options.programs.quickshell.localDev.enable =
        lib.mkEnableOption "Local development for quickshell config";

      homeManagerLinux =
        {
          pkgs,
          config,
          inputs',
          ...
        }:
        let
          quickshell = inputs'.quickshell.packages.default;

          # Qt 6.12 makes moc require complete types for QML class property
          # metatypes; quickshell's 0.2.1-era headers rely on opaque pointers, so
          # mocs_compilation fails with "Meta Types must be fully defined".
          # Backport of upstream quickshell commit 5d5d498 ("use MOC includes
          # instead of opaque pointer definitions"). Drop when the branch is
          # rebased onto upstream master.
          quickshellUnwrapped = quickshell.unwrapped.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./qt-6.12-moc-completeness.patch ];
          });

          # Same derivation as upstream's wrapper, repointing it at the patched
          # build so qtWrapperArgs/QML import paths are preserved.
          quickshellPatched = quickshell.overrideAttrs (_: {
            installPhase = ''
              mkdir -p $out
              cp -r ${quickshellUnwrapped}/* $out
            '';
          });
        in
        {
          programs.quickshell = {
            enable = true;
            activeConfig = null;
            systemd.enable = true;

            package = pkgs.symlinkJoin {
              name = "quickshell";
              paths = [ quickshellPatched ];
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
            pkgs.brightnessctl
            (pkgs.writeShellScriptBin "shell" ''
              exec quickshell ipc call actions "$@"
            '')
          ];

          home.file."Pictures/Wallpapers/main.png".source = config.stylix.image;

          xdg.configFile."quickshell".source =
            if config.programs.quickshell.localDev.enable then
              config.lib.file.mkOutOfStoreSymlink "${config.home.configDir}/modules/programs/quickshell/_config"
            else
              ./_config;
        };
    };
}
