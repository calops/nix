{ inputs, pkgs, ... }:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    (
      { pkgs, ... }:
      {
        packages = [
          pkgs.nil
          pkgs.nixd
          pkgs.lua-language-server
        ];
      }
    )
  ];
}
