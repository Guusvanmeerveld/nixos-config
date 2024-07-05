{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;
in {
  options = {
    custom.wm.wayland.sway = {
      enable = lib.mkEnableOption "Enable sway window manager";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.default = {
      name = "sway";
      path = "${pkgs.sway}/bin/sway";
    };

    security.pam.services.swaylock = {};
  };
}
