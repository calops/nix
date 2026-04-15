{ inputs, den, lib, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # ── NixOS hosts ──────────────────────────────────────────────
  den.hosts.x86_64-linux.tocardstation.users.calops = {};
  den.hosts.x86_64-linux.tb-laptop.users.calops = {};

  # ── Darwin hosts ─────────────────────────────────────────────
  den.hosts.aarch64-darwin.remilabeyrie-kiro.users.remilabeyrie = {};

  # ── Standalone home-manager ──────────────────────────────────
  den.homes.x86_64-linux.tocardland = {
    userName = "calops";
  };
}
