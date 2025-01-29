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
    };
  };

  config = lib.mkIf cfg.enable {
    programs.freetube = {
      enable = true;

      settings = {
        checkForUpdates = false;

        defaultQuality = "1440";

        baseTheme = "black";

        useSponsorBlock = true;
        sponsorBlockIntro = {
          color = "Cyan";
          skip = "autoSkip";
        };
      };
    };
  };
}
