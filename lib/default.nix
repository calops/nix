{ ... }: {
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

  caches = import ./caches.nix;
}
