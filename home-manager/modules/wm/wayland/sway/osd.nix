{
  lib,
  config,
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
    services.swayosd = {
      enable = true;
    };
  };
}
