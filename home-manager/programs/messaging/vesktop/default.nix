{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.vesktop;

  jsonFormat = pkgs.formats.json {};
in {
  options = {
    custom.programs.messaging.vesktop = {
      enable = lib.mkEnableOption "Enable Vesktop Discord client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [vesktop];

    xdg.configFile."vesktop/settings.json".source = jsonFormat.generate "vesktop-settings" {
      "discordBranch" = "stable";
      "splashColor" = "oklab(0.899401 -0.00192499 -0.00481987)";
      "splashBackground" = "oklab(0.321088 -0.000220731 -0.00934622)";
      "customTitleBar" = false;
      "staticTitle" = true;
      "splashTheming" = true;
      "disableSmoothScroll" = true;
      "checkUpdates" = false;
      "minimizeToTray" = false;
      "arRPC" = true;
    };
  };
}
