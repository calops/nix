{ pkgs, perSystem }:
pkgs.writeShellApplication {
  name = "linear";
  runtimeInputs = with pkgs; [
    nodejs
    perSystem.self.op-credential
  ];
  text = ''
    eval "$(op-credential "Linear API Key" LINEAR_API_KEY)"
    exec npx -y @schpet/linear-cli "$@"
  '';
}
