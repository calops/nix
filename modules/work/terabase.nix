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
              core.sshCommand = ''ssh -i "$(op-ssh-key 'Terabase Bitbucket key')"'';
              user = {
                name = "Rémi Labeyrie";
                email = "rlabeyrie@terabase.energy";
                signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK4tZxLZ9PwBd0IrOhzSFMlqW5aB9sKboCszPya4B7n";
              };
            };
          }
        ];

        programs.fish.functions.gh = {
          wraps = "gh";
          body = # fish
            ''
              if test (pwd) = "$HOME/terabase"; or string match -q "$HOME/terabase/*" (pwd)
                  GH_CONFIG_DIR="$HOME/terabase/.gh" command gh $argv
              else
                  command gh $argv
              end
            '';
        };

        home.packages = [
          pkgs.teams-for-linux
        ];
      };
  };
}
