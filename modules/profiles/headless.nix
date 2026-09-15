{ lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "headless" {
  # Machines without a running 1Password desktop app (no SSH agent socket).
  # Instead of relying on `op-ssh-key` + the 1Password agent, these hosts run a
  # local ssh-agent populated from 1Password. See modules/programs/onepassword.nix.
  homeManager.dconf.enable = false;
}
