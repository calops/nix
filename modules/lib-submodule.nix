{ den, ... }:
let
  myLib = {
    mkGraphicalSessionService =
      { description, command }:
      {
        Unit = {
          Description = description;
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = command;
          Restart = "on-failure";
          KillMode = "mixed";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
  };
in
{
  den.aspects.mylib = {
    nixos._module.args.myLib = myLib;
    darwin._module.args.myLib = myLib;
    homeManager._module.args.myLib = myLib;
  };

  den.default.includes = [ den.aspects.mylib ];
}
