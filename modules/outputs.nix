{
  den,
  inputs,
  lib,
  ...
}:
{
  systems = builtins.attrNames den.hosts;

  den.ctx.flake-packages.includes = [ den.aspects.outputs ];
  den.ctx.flake-system.into.host =
    { system }: lib.attrValues (den.hosts.${system} or { }) |> (host: { inherit host; });

  den.default.includes = [ den.aspects.outputs ];
  den.aspects.outputs = {
    formatter = { pkgs, ... }: pkgs.nixfmt-tree;
  };
}
