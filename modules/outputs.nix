{
  den,
  lib,
  ...
}:
{
  systems = builtins.attrNames den.hosts;

  den.ctx.flake-system.into.host =
    { system }: lib.attrValues (den.hosts.${system} or { }) |> (host: { inherit host; });

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

      devShells.default = pkgs.mkShell {
        NIX_CONFIG = ''
          extra-experimental-features = flakes nix-command pipe-operators
          extra-substituters = https://cache.garnix.io https://cache.nixos.org https://calops.cachix.org https://nix-community.cachix.org https://anyrun.cachix.org https://niri.cachix.org https://nix-darwin.cachix.org
          extra-trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s= niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964= nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A=
        '';
      };
    };
}
