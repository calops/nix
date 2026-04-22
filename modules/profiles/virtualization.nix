{ den, lib, ... }:
{
  den.default.defineOptions.profiles.virtualization.enable = lib.mkEnableOption "Virtualization";

  den.aspects.virtualization = {
    setOptions.profiles.virtualization.enable = true;

    nixos = {
      virtualisation.waydroid.enable = true;
      virtualisation.virtualbox = {
        host.enable = true;
        host.enableExtensionPack = true;
      };
      boot.blacklistedKernelModules = [ "kvm-intel" ];
    };
  };
}
