{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.adb;
in {
  options = {
    custom.programs.adb = {
      enable = lib.mkEnableOption "Enable Android build tools";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [android-tools];
    services.udev.packages = with pkgs; [android-udev-rules];
    users.groups.adbusers = {};

    custom.usersGlobalGroups = ["adbusers"];
  };
}
