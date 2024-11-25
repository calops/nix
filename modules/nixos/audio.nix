{ lib, config, ... }:
{
  options.my.roles.audio.enable = lib.mkEnableOption "Enable audio";

  config = lib.mkIf config.my.roles.audio.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    hardware.pulseaudio.enable = false;
  };
}
