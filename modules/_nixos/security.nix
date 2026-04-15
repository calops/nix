{ inputs, ... }:
{
  imports = [
    "${inputs.howdy-nixpkgs}/modules/nixos/security.nix"
  ];

  # TODO: wait for https://github.com/NixOS/nixpkgs/pull/216245 to be merged
  services.linux-enable-ir-emitter.enable = true;
  services.howdy.enable = true;
}
