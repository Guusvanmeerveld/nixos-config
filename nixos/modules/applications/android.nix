{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.android;
in {
  options = {
    custom.applications.android = {
      enable = lib.mkEnableOption "Enable Android build tools";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs.unstable; [android-tools];
    services.udev.packages = with pkgs.unstable; [android-udev-rules];
    users.groups.adbusers = {};
  };
}
