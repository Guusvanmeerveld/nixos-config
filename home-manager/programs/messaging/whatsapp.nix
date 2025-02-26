{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.whatsapp;
in {
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
    home.packages =
      [
        cfg.package
      ]
      ++ lib.optional cfg.autostart (pkgs.makeAutostartItem {
        name = "com.ktechpit.whatsie";
        package = cfg.package;
      });
  };
}
