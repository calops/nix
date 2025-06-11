{ lib, ... }:
{
  imports = lib.snowfall.fs.get-non-default-nix-files (
    builtins.path {
      path = ./.;
      name = "source";
    }
  );
}
