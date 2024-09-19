{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.mpv;
in {
  options = {
    custom.applications.graphical.mpv = {
      enable = lib.mkEnableOption "Enable MPV video player";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;

      config = {
        force-window = true;
        ytdl-format = "bestvideo+bestaudio";
      };
    };
  };
}
