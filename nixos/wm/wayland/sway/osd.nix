{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway.osd;
in {
  options = {
    custom.wm.wayland.sway.osd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.sway.enable;
        description = "Enable sway osd";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = with pkgs; [swayosd];

    systemd.services.swayosd-libinput-backend = {
      enable = true;

      wantedBy = ["graphical.target"];
    };

    services = {
      udev.packages = with pkgs; [swayosd];
      dbus.packages = with pkgs; [swayosd];
    };

    environment.systemPackages = with pkgs; [swayosd];
  };
}
