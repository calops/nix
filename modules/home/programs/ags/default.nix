{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  system = "x86_64-linux";
  ags = inputs.ags.packages.${system};
  deps = [
    pkgs.sassc
    pkgs.bun
    ags.tray
    ags.mpris
    ags.network
    ags.wireplumber
  ];
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.ags = {
      enable = true;
      configDir = null;
      package = ags.agsFull.overrideAttrs {
        postFixup = ''
          wrapProgram $out/bin/ags --prefix PATH : ${lib.makeBinPath deps}
        '';
      };
      extraPackages = deps;
    };

    xdg.configFile."ags".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/ags/config";

    systemd.user.services.ags-bar = {
      Unit = {
        Description = "AGS Bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service =
        let
          ags = "${config.programs.ags.package}/bin/ags";
        in
        {
          ExecStart = "${ags} run";
          ExecReload = "${ags} quit && ${ags} run";
          Restart = "on-failure";
          KillMode = "mixed";
        };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
