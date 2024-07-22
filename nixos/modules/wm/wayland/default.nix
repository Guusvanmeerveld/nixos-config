{
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;
in {
  imports = [./sway];

  options = {
    custom.wm.wayland = {
      enable = lib.mkEnableOption "Enable wayland support";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.portal.wlr.enable = true;
  };
}
