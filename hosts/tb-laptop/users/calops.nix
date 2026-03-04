{ flake, pkgs, ... }:
{
  imports = [
    flake.homeModules.default
  ];

  my.roles.terminal.enable = true;

  my.roles.graphical = {
    installAllFonts = true;
    terminal = "kitty";

    niriExtraConfig = # kdl
      ''
        output "China Star Optoelectronics Technology Co., Ltd MNE507ZA2-3 Unknown" {
          mode "3072x1920@120.000"
          focus-at-startup
          variable-refresh-rate

          layout {
            default-column-width { proportion 0.5; }
          }
        }

        output "LG Electronics LG ULTRAFINE 505NTNHGX503" {
          position x=-3072 y=0
        }
      '';
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/terabase/";
      contents = {
        core.sshCommand = "ssh -i ~/.ssh/terabase-bitbucket.pub";

        user = {
          name = "Rémi Labeyrie";
          email = "remilabeyrie@terabase.energy";
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK4tZxLZ9PwBd0IrOhzSFMlqW5aB9sKboCszPya4B7n";
        };
      };
    }
  ];

  programs.ssh.matchBlocks.bitbucket = {
    hostname = "bitbucket.org";
    identitiesOnly = true;
    identityFile = "~/.ssh/terabase-bitbucket.pub";
  };

  home.packages = [
    pkgs.teams-for-linux
  ];
}
