{
  lib,
  config,
  pkgs,
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
    custom.wm.default = {
      name = "i3";
      path = "${pkgs.i3}/bin/i3";
    };

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
