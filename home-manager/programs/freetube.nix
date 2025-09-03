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

      defaultResolution = lib.mkOption {
        type = lib.types.enum ["1080" "1440" "2160"];
        default = "1080";
        description = "Default resolution for video player";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit (config.programs.freetube) package;
        appId = "FreeTube";
        workspace = 5;
        keybind = "$mod+r";
      }
    ];

    programs.freetube = {
      enable = true;

      settings = {
        checkForUpdates = false;

        defaultQuality = cfg.defaultResolution;
        defaultVolume = 0.4;
        autoplayVideos = true;

        baseTheme = "black";

        hideTrendingVideos = true;
        hidePopularVideos = true;
        hideHeaderLogo = true;

        useSponsorBlock = true;
        sponsorBlockIntro = {
          color = "Cyan";
          skip = "autoSkip";
        };
      };
    };
  };
}
