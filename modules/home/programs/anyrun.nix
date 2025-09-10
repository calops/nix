{
  config,
  lib,
  perSystem,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
let
  anyrunPkgs = perSystem.anyrun;
  palette = config.my.colors.palette.asRgbIntTuple;
in
{
  imports = [ inputs.anyrun.homeManagerModules.default ];
  disabledModules = [ "${modulesPath}/programs/anyrun.nix" ];

  config = lib.mkIf (config.my.roles.graphical.enable && pkgs.stdenv.isLinux) {
    programs.anyrun = {
      package = anyrunPkgs.anyrun;
      enable = true;

      config = {
        y.fraction = 0.3;
        plugins = [
          anyrunPkgs.niri-focus
          anyrunPkgs.rink
          anyrunPkgs.applications
          anyrunPkgs.shell
          anyrunPkgs.dictionary
          anyrunPkgs.symbols
          anyrunPkgs.translate
          anyrunPkgs.nix-run
        ];
      };

      extraCss = # css
        ''
          window {
            border: 2px solid rgb(${palette.red});
            background-color: rgb(${palette.mantle});
            border-radius: 8px;
          }

          .main {
            margin: 5px;
          }

          text {
            padding: 5px;
            margin: 5px;
            background-color: rgb(${palette.surface1});
            border-radius: 4px;
          }

          box.plugin {
            margin: 5px;
            padding: 5px;
            border-radius: 4px;
            background-color: rgb(${palette.base});
          }

          box.plugin.info {
            min-width: 150px;
          }

          box.plugin .info box.horizontal label {
            padding-left: 5px;
            border-radius: 4px;
          }

          box.plugin list {
             background-color: ${palette.base};
          }

          box.plugin list .match .title,
          box.plugin list .match .description {
            padding: 5px;
          }

          list.plugin .match:selected {
            background-color: rgb(${palette.overlay0});
            border-radius: 4px;
          }
        '';

      extraConfigFiles."nix-run.ron".text = # ron
        ''
          Config(
            prefix: ", ",
            allow_unfree: true,
            channel: "nixpkgs-unstable",
            max_entries: 5,
          )
        '';
    };
  };
}
