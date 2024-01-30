{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.roles.gaming;
in
  with lib; {
    options = {
      my.roles.gaming.enable = mkEnableOption "Enable gaming configuration";
    };
  }
