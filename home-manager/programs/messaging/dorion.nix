{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.dorion;

  jsonFormat = pkgs.formats.json {};
in {
  options = {
    custom.programs.messaging.dorion = {
      enable = lib.mkEnableOption "Enable Dorion Discord client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [dorion];

    xdg.configFile."dorion/config.json".source = jsonFormat.generate "dorion-settings" {
      "theme" = null;
      "zoom" = "1.0";
      "client_type" = "default";
      "sys_tray" = false;
      "block_telemetry" = true;
      "push_to_talk" = null;
      "push_to_talk_keys" = null;
      "cache_css" = true;
      "use_native_titlebar" = true;
      "start_maximized" = false;
      "profile" = null;
      "streamer_mode_detection" = false;
      "rpc_server" = false;
      "open_on_startup" = false;
      "startup_minimized" = false;
      "autoupdate" = false;
      "update_notify" = null;
      "desktop_notifications" = null;
      "auto_clear_cache" = null;
      "multi_instance" = false;
      "disable_hardware_accel" = false;
      "blur" = null;
      "blur_css" = null;
      "client_mods" = ["Shelter"];
      "unread_badge" = null;
      "client_plugins" = null;
    };
  };
}
