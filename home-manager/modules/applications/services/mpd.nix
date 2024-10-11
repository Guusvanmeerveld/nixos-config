{
  outputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.mpd;
in {
  imports = [outputs.homeManagerModules.mpdris2];

  options = {
    custom.applications.services.mpd = {
      enable = lib.mkEnableOption "Enable MPD";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mpd = {
      enable = true;

      mpris.enable = true;

      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
      '';
    };
  };
}
