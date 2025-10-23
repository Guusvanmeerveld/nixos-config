{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.mpv;

  desktopFile = "mpv.desktop";

  openByDefault = [
    # Video
    "video/mp4"
    "video/webm"
    "video/ogg"

    # Audio
    "audio/mpeg"
    "audio/wav"
    "audio/ogg"
    "audio/aac"

    # Subtitle
    "text/srt"
    "application/x-subrip"
  ];
in {
  options = {
    custom.programs.mpv = {
      enable = lib.mkEnableOption "Enable MPV video player";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = builtins.listToAttrs (map (mimeType: {
        name = mimeType;
        value = desktopFile;
      })
      openByDefault);

    programs.mpv = {
      enable = true;

      scripts = with pkgs.mpvScripts; [mpv-osc-modern];

      config = {
        force-window = true;
        ytdl-format = "bestvideo+bestaudio";

        volume = 50;

        save-position-on-quit = true;
      };
    };
  };
}
