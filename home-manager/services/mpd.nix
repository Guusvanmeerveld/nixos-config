{
  outputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.mpd;
in {
  imports = [outputs.homeManagerModules.mpdris2];

  options = {
    custom.services.mpd = {
      enable = lib.mkEnableOption "Enable MPD";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mpd = {
      enable = true;

      mpris.enable = true;

      playlistDirectory = config.xdg.userDirs.music + "/playlists";

      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }

        auto_update "yes"
      '';
    };
  };
}
