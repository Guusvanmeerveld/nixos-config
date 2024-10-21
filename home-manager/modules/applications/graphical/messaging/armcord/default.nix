{
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.messaging.armcord;
in {
  imports = [outputs.homeManagerModules.armcord];

  options = {
    custom.applications.graphical.messaging.armcord = {
      enable = lib.mkEnableOption "Enable Armcord Discord client";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.armcord = {
      enable = true;

      package = pkgs.goofcord;

      configDir = "goofcord";

      settings = {
        "customTitlebar" = true;
        "minimizeToTray" = false;
        "startMinimized" = false;

        "dynamicIcon" = false;
        "customIconPath" = ./discord.png;

        "autoscroll" = false;
        "transparency" = false;

        "modName" = "vencord";
        "customJsBundle" = "";
        "customCssBundle" = "";
        "noBundleUpdates" = false;

        "firewall" = true;
        "customFirewallRules" = false;
        "blocklist" = ["https://*/api/v*/science" "https://*/api/v*/applications/detectable" "https://*/api/v*/auth/location-metadata" "https://*/assets/version.*" "https://*/api/v*/premium-marketing" "https://*/api/v*/scheduled-maintenances/upcoming.json" "https://cdn.discordapp.com/bad-domains/*" "https://www.youtube.com/youtubei/v*/next?*" "https://www.youtube.com/s/desktop/*" "https://www.youtube.com/youtubei/v*/log_event?*"];
        "blockedStrings" = ["sentry" "google" "tracking" "stats" "\\.spotify" "pagead" "analytics"];
        "allowedStrings" = ["videoplayback" "discord-attachments" "googleapis" "search" "api.spotify"];
        "scriptLoading" = true;
        "autoUpdateDefaultScripts" = true;

        # Encryption
        "messageEncryption" = false;
        "encryptionPasswords" = [];
        "encryptionCover" = "";
        "encryptionMark" = "| ";

        "arrpc" = false;
        "launchWithOsBoot" = false;
        "spellcheck" = true;
        "updateNotification" = false;
        "disableAutogain" = false;
        "discordUrl" = "https://discord.com/app";

        "screensharePreviousSettings" = ["1080" "30" false];
      };
    };
  };
}
