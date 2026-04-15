{
  config,
  lib,
  perSystem,
  ...
}:
{
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = [ perSystem.self.linear-cli ];
  };
}
