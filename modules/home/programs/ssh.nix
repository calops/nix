{
  lib,
  config,
  ...
}:
{
  options = {
    my.roles.terminal.ssh.hosts = lib.mkOption {
      default = { };
      description = "List of available SSH hosts";
    };
  };
  config = {
    programs.ssh = {
      enable = config.my.roles.terminal.enable;
      matchBlocks = {
        tocards = {
          hostname = "tocards.net";
          user = "calops";
        };
      } // config.my.roles.terminal.ssh.hosts;
    };
  };
}
