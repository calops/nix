{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    my.roles.terminal.ssh.hosts = lib.mkOption {
      default = { };
      description = "List of available SSH hosts";
    };
  };
  config =
    let
      onePassPath =
        if pkgs.stdenv.isDarwin then
          "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        else
          "~/.1password/agent.sock";
    in
    {
      programs.ssh = {
        enable = config.my.roles.terminal.enable;
        matchBlocks = {
          tocards = {
            hostname = "tocards.net";
            user = "calops";
          };
        } // config.my.roles.terminal.ssh.hosts;
        # FIXME: 1P is bugged
        # extraConfig = ''
        #     IdentityAgent ${onePassPath}
        #   # '';
      };
    };
}
