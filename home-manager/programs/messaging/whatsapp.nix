{
  lib,
  config,
  outputs,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.whatsapp;
in {
  imports = [outputs.homeManagerModules.whatsie];

  options = {
    custom.programs.messaging.whatsapp = {
      enable = lib.mkEnableOption "Enable Whatsapp for Linux";

      package = lib.mkPackageOption pkgs "whatsie" {};

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
        inherit (cfg) package;
        appId = "com.ktechpit.whatsie";
        keybind = "$mod+v";
        workspace = 1;
      }
    ];

    home.packages = lib.optional cfg.autostart (pkgs.makeAutostartItem {
      name = "com.ktechpit.whatsie";
      inherit (cfg) package;
    });

    programs.whatsie = {
      enable = true;

      inherit (cfg) package;

      settings = {
        General = {
          firstrun_tray = false;
          notificationCombo = 0;
          widgetStyle = "kvantum-dark";
          windowTheme = "dark";
        };

        permissions = {
          Notifications = true;
        };
      };
    };
  };
}
