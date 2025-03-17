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

        env.NVIM_LSP_SERVERS = "nil_ls nixd lua-language-server";
      }
    )
  ];
}
