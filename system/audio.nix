{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.audio.enable {
    sound.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    hardware.pulseaudio.enable = false;
  };
}
