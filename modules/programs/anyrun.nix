{ inputs', ... }:
{
  flake-file.inputs = {
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.programs.anyrun = {
    nix.extra-substituters = [ "https://anyrun.cachix.org" ];
    nix.extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];

    homeManagerLinux =
      { modulesPath, colors, ... }:
      {
        imports = [ inputs'.anyrun.homeManagerModules.default ];
        disabledModules = [ "${modulesPath}/programs/anyrun.nix" ];

        programs.anyrun =
          let
            anyrunPkgs = inputs'.packages.anyrun;
            palette = colors.palette.asRgbIntTuple;
          in
          {
            package = anyrunPkgs.anyrun;
            enable = true;

            config = {
              y.fraction = 0.3;
              plugins = [
                # Prefixed plugins come first
                anyrunPkgs.nix-run

                anyrunPkgs.actions
                anyrunPkgs.niri-focus
                anyrunPkgs.rink
                anyrunPkgs.applications
                anyrunPkgs.shell
                anyrunPkgs.dictionary
                anyrunPkgs.translate
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
  };
}
