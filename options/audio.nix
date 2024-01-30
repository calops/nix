{lib, ...}: {
  options = {
    my.roles.audio.enable = lib.mkEnableOption "Enable audio";
  };
}
