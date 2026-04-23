{ ... }:
{
  den.aspects.programs.provides.linear = {
    homeManager =
      { pkgs, self', ... }:
      {
        home.packages = [
          (pkgs.writeShellApplication {
            name = "linear";
            runtimeInputs = with pkgs; [
              nodejs
              self'.packages.op-credential
            ];
            text = ''
              eval "$(op-credential "Linear API Key" LINEAR_API_KEY)"
              exec npx -y @schpet/linear-cli "$@"
            '';
          })
        ];
      };
  };
}
