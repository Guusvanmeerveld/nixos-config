{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.mpd;
in {
  options = {
    custom.applications.services.mpd = {
      enable = lib.mkEnableOption "Enable MPD";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mpd = {
      enable = true;

      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
      '';
    };
  };
}
