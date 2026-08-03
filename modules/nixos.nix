{ lib, ... }:
{
  flake-file.inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  den.schema.host.includes = [
    {
      nixos =
        {
          pkgs,
          host,
          config,
          ...
        }:
        {
          config = {
            # Settings
            system.stateVersion = "26.05";
            nixpkgs.config.allowUnfree = true;
            hardware.enableAllFirmware = true;
            virtualisation.docker.enable = true;
            security.rtkit.enable = true;
            security.polkit.enable = true;
            home-manager.backupFileExtension = "hm-backup";
            networking.networkmanager.enable = true;

            system.activationScripts.nixosConfigDir = {
              text =
                let
                  path = lib.escapeShellArg host.configDir;
                  target = lib.escapeShellArg "${config.users.users.calops.home}/nix";
                in
                ''
                  path=${path}
                  target=${target}

                  if [ ! -d "$target" ]; then
                    echo "Nix configuration checkout is missing: $target" >&2
                    exit 1
                  fi

                  if [ -L "$path" ]; then
                    if [ "$(readlink "$path")" != "$target" ]; then
                      echo "$path links to a different checkout: $(readlink "$path")" >&2
                      exit 1
                    fi
                  elif [ -e "$path" ]; then
                    echo "Refusing to replace existing non-symlink path: $path" >&2
                    exit 1
                  else
                    ln -s "$target" "$path"
                  fi
                '';
            };

            i18n = {
              defaultLocale = "en_US.UTF-8";
              extraLocaleSettings = {
                LC_ADDRESS = "fr_FR.UTF-8";
                LC_IDENTIFICATION = "fr_FR.UTF-8";
                LC_MEASUREMENT = "fr_FR.UTF-8";
                LC_MONETARY = "fr_FR.UTF-8";
                LC_NAME = "fr_FR.UTF-8";
                LC_NUMERIC = "fr_FR.UTF-8";
                LC_PAPER = "fr_FR.UTF-8";
                LC_TELEPHONE = "fr_FR.UTF-8";
                LC_TIME = "en_US.UTF-8";
              };
            };

            # Boot
            boot = {
              initrd.systemd.enable = true;
              loader = {
                efi.canTouchEfiVariables = true;
                systemd-boot = {
                  enable = true;
                  consoleMode = "max";
                };
              };
              supportedFilesystems = [ "ntfs" ];
            };

            nix = {
              optimise.automatic = true;
              gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 30d";
              };
            };

            # Programs
            programs.nix-ld = {
              enable = true;
              libraries = [
                pkgs.stdenv.cc.cc
                pkgs.zlib
                pkgs.fuse3
                pkgs.icu
                pkgs.nss
                pkgs.openssl
                pkgs.curl
                pkgs.expat
              ];
            };

            programs.fish.enable = true;
            programs.mtr.enable = true;
            programs.gnupg.agent = {
              enable = true;
              enableSSHSupport = true;
            };

            # FIXME: nvim.nix
            environment.sessionVariables.EDITOR = "nvim";

            # Services
            services.udisks2.enable = true;
            services.openssh.enable = true;
            services.fwupd.enable = true;
            services.acpid.enable = true;
            hardware.acpilight.enable = true;
            services.udev.extraRules = ''
              ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="kbd_backlight", GROUP="video", MODE="0664"
            '';
          };
        };
    }
  ];
}
