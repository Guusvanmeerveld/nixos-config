{
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.x11.i3;
in {
  options = {
    custom.wm.x11.i3 = {
      enable = lib.mkEnableOption "Enable i3 wm";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;

        windowManager.i3 = {
          enable = true;
        };
      };
    };
  };
}
