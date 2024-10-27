{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.mpv;

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
    custom.applications.graphical.mpv = {
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

      config = {
        force-window = true;
        ytdl-format = "bestvideo+bestaudio";

        save-position-on-quit = true;
      };
    };
  };
}
