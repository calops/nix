{ inputs, pkgs, ... }:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    (
      { pkgs, ... }:
      {
        languages.python = {
          enable = true;
          venv.enable = true;
          uv.enable = true;
        };

        packages = [
          pkgs.python3Packages.pip
          pkgs.ty # type checker
          pkgs.ruff # linter
        ];
      }
    )
  ];
}
