{
  outputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.wayland.clipmon;
in {
  imports = [outputs.homeManagerModules.clipmon];

  options = {
    custom.wm.wayland.clipmon = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.enable;
        description = "Enable clipman clipboard service";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.clipmon.enable = true;
  };
}
