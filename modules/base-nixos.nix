{ inputs, den, lib, config, perSystem, pkgs, ... }:
{
  den.aspects.base-nixos = {
    nixos =
      { config, pkgs, lib, perSystem, ... }:
      {
        imports = [
          inputs.stylix.nixosModules.stylix
          inputs.nix-index-database.nixosModules.nix-index
          ../_common
        ];

        options = {
          my.configDir = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            apply = toString;
            default = null;
            description = "Location of the nix config directory (this repo)";
          };
        };

        config = {
          system.stateVersion = "26.05";

          boot = {
            initrd.systemd.enable = true;
            loader = {
              efi.canTouchEfiVariables = true;
              systemd-boot = {
                enable = true;
                consoleMode = "max";
              };
            };
            kernel.sysctl = {
              "fs.inotify.max_user_watches" = 100000;
              "fs.inotify.max_queued_events" = 100000;
            };
            supportedFilesystems = [ "ntfs" ];
          };

          hardware.enableAllFirmware = true;
          hardware.graphics.enable = true;

          virtualisation.docker.enable = true;

          nixpkgs.config.allowUnfree = true;
          nix = {
            optimise.automatic = true;
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 30d";
            };
          };

          stylix.homeManagerIntegration.autoImport = false;
          stylix.overlays.enable = false;

          home-manager.backupFileExtension = "hm-backup";

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
          programs.nh = {
            package = perSystem.self.nh;
            enable = true;
            clean.enable = false;
            clean.extraArgs = "--keep-since 14d --keep 5";
            flake = config.my.configDir;
          };
          programs._1password.enable = true;
          programs._1password-gui.enable = true;

          environment.sessionVariables.EDITOR = "nvim";
          environment.etc."1password/custom_allowed_browsers" = {
            text = ''
              firefox-beta
            '';
            mode = "0755";
          };

          console = {
            font = "ter-124b";
            keyMap = lib.mkDefault "fr";
            packages = [ perSystem.self.fonts.terminus.package ];
            earlySetup = true;
          };

          networking.networkmanager.enable = true;

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
              LC_TIME = "fr_FR.UTF-8";
            };
          };

          services.udisks2.enable = true;
          services.openssh.enable = true;
          services.acpid.enable = true;
          hardware.acpilight.enable = true;
          services.udev.extraRules = ''
            ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="kbd_backlight", GROUP="video", MODE="0664"
          '';

          security.rtkit.enable = true;
          security.polkit.enable = true;
        };
      };
  };
}
