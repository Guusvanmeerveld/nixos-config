{
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.wayland.sway.vnc;
in {
  options = {
    custom.wm.wayland.sway.vnc = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.sway.enable;
        description = "Enable wayvnc";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.wayvnc = {
      enable = true;
      autoStart = true;

      settings = {
        address = "localhost";
        port = 5901;
      };
    };
  };
}
