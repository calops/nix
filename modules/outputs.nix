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
      formatter = pkgs.nixfmt-tree;
    };
}
