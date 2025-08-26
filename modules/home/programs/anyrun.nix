{
  config,
  lib,
  perSystem,
  pkgs,
  ...
}:
let
  anyrunPkgs = perSystem.anyrun;
  palette = config.my.colors.palette.asRgbIntTuple;
in
{
  config = lib.mkIf (config.my.roles.graphical.enable && pkgs.stdenv.isLinux) {
    programs.anyrun = {
      package = anyrunPkgs.anyrun;
      enable = true;

      config = {
        y.fraction = 0.3;
        plugins = [
          anyrunPkgs.applications
          anyrunPkgs.rink
          anyrunPkgs.shell
          anyrunPkgs.dictionary
          anyrunPkgs.symbols
          anyrunPkgs.translate
          anyrunPkgs.niri-focus
          anyrunPkgs.nix-run
        ];
      };

      extraCss = # css
        ''
          #window {
            background-color: rgba(${palette.base}, 0.4);
          }

          box#main {
            border-radius: 10px;
            background-color: rgb(${palette.mantle});
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

      extraConfigFiles."nix-run.ron".text = # ron
        ''
          Config(
            prefix: ", ",
            allow_unfree: true,
            channel: "nixpkgs-unstable",
            max_entries: 3,
          )
        '';
    };
  };
}
