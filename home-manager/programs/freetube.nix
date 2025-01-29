{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.freetube;
in {
  options = {
    custom.programs.freetube = {
      enable = lib.mkEnableOption "Enable Freetube Youtube client";

      defaultResolution = {
        type = lib.types.enum ["1080" "1440" "2160"];
        default = "1080";
        description = "Default resolution for video player";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.freetube = {
      enable = true;

      settings = {
        checkForUpdates = false;

        defaultQuality = cfg.defaultResolution;
        autoplayVideos = true;

        baseTheme = "black";

        hideTrendingVideos = true;
        hidePopularVideos = true;

        useSponsorBlock = true;
        sponsorBlockIntro = {
          color = "Cyan";
          skip = "autoSkip";
        };
      };
    };
  };
}
