{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.vesktop;

  package = cfg.package.overrideAttrs (_old: {
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
    custom.wm.applications = [
      {
        inherit (config.programs.vesktop) package;
        appId = "vesktop";
        keybind = "$mod+z";
        workspace = 1;
      }
    ];

    home.packages = lib.optional cfg.autostart (pkgs.makeAutostartItem {
      name = "vesktop";
      inherit package;
    });

    programs.vesktop = {
      enable = true;

      inherit package;

      settings = {
        tray = true;
        enableSplashScreen = false;
        hardwareVideoAcceleration = true;
      };

      vencord.settings = {
        autoUpdate = false;

        plugins = {
          "BiggerStreamPreview".enabled = true;
          "CallTimer".enabled = true;
          "BetterSettings".enabled = true;
          "AlwaysTrust".enabled = true;
          "FriendsSince".enabled = true;
          "MemberCount".enabled = true;
          "NotificationVolume".enabled = true;
          "NoTypingAnimation".enabled = true;
          "NoF1".enabled = true;
          "ShowHiddenThings".enabled = true;
          "FakeNitro".enabled = true;
          "OpenInApp".enabled = true;
          "ReverseImageSearch".enabled = true;
          "ServerInfo".enabled = true;
          "ServerListIndicators".enabled = true;
          "StartupTimings".enabled = true;
          "VolumeBooster".enabled = true;
          "ShikiCodeblocks".enabled = true;
        };
      };
    };
  };
}
