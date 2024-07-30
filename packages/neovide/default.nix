{ pkgs, inputs, ... }:
pkgs.neovide.override { neovim = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim; }
