{ inputs, den, lib, ... }:
{
  den.aspects.terminal = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.jq ];
    };
  };
}
