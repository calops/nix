{
  inputs,
  pkgs,
  ...
}:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    {
      languages.rust = {
        enable = true;
        channel = "nightly";
      };

      pre-commit.hooks = {
        clippy.enable = true;
        rustfmt.enable = true;
      };
    }
  ];
}
