{ ... }:
{
  den.aspects.work.provides.terabase = {
    homeManager =
      {
        pkgs,
        lib,
        self',
        ...
      }:
      {
        # `tb task` (construct-backend-nix) reads Linear's API over HTTP rather
        # than shelling out to a CLI, so it needs a key. It takes either
        # LINEAR_API_KEY directly or a command that prints one -- the latter so a
        # secret manager stays out of that flake.
        home.sessionVariables.TB_LINEAR_API_KEY_CMD = "${lib.getExe self'.packages.op-credential} --raw 'Linear API Key'";

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
