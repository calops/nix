{
  config,
  lib,
  perSystem,
  pkgs,
  ...
}:
let
  anyrunPkgs = perSystem.anyrun;
  palette = config.my.colors.palette.asGtkCss;
in
{
  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
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

      extraCss =
        # css
        ''
          @import url("${palette}");

          #window {
            background-color: rgba(30, 30, 46, 0.4); /* palette.base */
          }

          box#main {
            border-radius: 10px;
            background-color: @palette-mantle;
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
