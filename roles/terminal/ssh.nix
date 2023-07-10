{
  config,
  lib,
  ...
}: let
  cfg = config.my.roles.terminal;
in
  with lib; {
    options = {
      my.roles.terminal.ssh.hosts = mkOption {
        default = {};
        description = "List of available SSH hosts";
      };
    };
    config = {
      programs.ssh = {
        enable = cfg.enable;
        matchBlocks =
          {
            tocards = {
              hostname = "tocards.net";
              user = "calops";
            };
            charybdis = {
              hostname = "charybdis.stockly.tech";
              user = "rlabeyrie";
              port = 23;
            };
          }
          // cfg.ssh.hosts;
      };
    };
  }
