{ lib, ... }:
{
  mkIfNotNull = val: lib.mkIf (val != null);
  firstNotNull = vals: lib.findFirst (val: val != null) vals;

  asLua = value: lib.generators.toLua { } value;

  enumerateList = list: lib.listToAttrs (lib.imap1 (x: y: lib.nameValuePair (toString x) y) list);

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
}
