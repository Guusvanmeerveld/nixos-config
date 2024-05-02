{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.sound;
in {
  options = {
    custom.sound = {
      enable = lib.mkEnableOption "Enable sound support";
    };
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      pulse.enable = true;
    };

    hardware = {
      pulseaudio.enable = false;
    };
  };
}
