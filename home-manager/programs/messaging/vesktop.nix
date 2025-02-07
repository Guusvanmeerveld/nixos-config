{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.vesktop;

  package = cfg.package.overrideAttrs (old: {
    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "vesktop";
        desktopName = "Vesktop";
        comment = "Better Discord client with improved Linux support and native Vencord";
        exec = "vesktop %U";
        icon = "discord";
        keywords = [
          "discord"
          "vencord"
          "electron"
          "chat"
        ];
        startupWMClass = "Vesktop";
        categories = ["Network" "InstantMessaging" "Chat"];
      })
    ];
  });

  jsonFormat = pkgs.formats.json {};
in {
  options = {
    custom.programs.messaging.vesktop = {
      enable = lib.mkEnableOption "Enable Vesktop Discord client";
      package = lib.mkPackageOption pkgs "vesktop" {};
      autostart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to autostart this application";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [
        package
      ]
      ++ lib.optional cfg.autostart (pkgs.makeAutostartItem {
        name = "vesktop";
        package = package;
      });

    xdg.configFile."vesktop/settings.json".source = jsonFormat.generate "vesktop-settings" {
      "discordBranch" = "stable";
      "splashColor" = "oklab(0.899401 -0.00192499 -0.00481987)";
      "splashBackground" = "oklab(0.321088 -0.000220731 -0.00934622)";
      "customTitleBar" = false;
      "staticTitle" = true;
      "splashTheming" = true;
      "disableSmoothScroll" = false;
      "checkUpdates" = false;
      "minimizeToTray" = true;
      "arRPC" = true;
    };
  };
}
