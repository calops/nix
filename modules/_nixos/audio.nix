{ lib, config, ... }:
{
  options.my.roles.audio.enable = lib.mkEnableOption "Enable audio";

  config = lib.mkIf config.my.roles.audio.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;

      # Airplay support
      raopOpenFirewall = true;
      extraConfig.pipewire = {
        "10-airplay" = {
          "context.modules" = [
            { name = "libpipewire-module-raop-discover"; }
          ];
        };
      };
    };
  };
}
