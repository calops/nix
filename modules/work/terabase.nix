{ ... }:
{
  den.aspects.work.provides.terabase = {
    homeManager =
      { pkgs, ... }:
      {
        programs.git.includes = [
          {
            condition = "gitdir:~/terabase/";
            contents = {
              core.sshCommand = "ssh -i ~/.ssh/terabase-bitbucket.pub";
              user = {
                name = "Rémi Labeyrie";
                email = "rlabeyrie@terabase.energy";
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
      };
  };
}
