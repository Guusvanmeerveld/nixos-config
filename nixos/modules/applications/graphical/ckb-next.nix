{
  config,
  lib,
  ...
}: let
  cfg = config.custom.applications.graphical;
in {
  options = {
    custom.applications.graphical.corsairKeyboard = lib.mkEnableOption "Enable corsair keyboard support application";
  };

  config = lib.mkIf cfg.corsairKeyboard {
    hardware.ckb-next.enable = true;
  };
}
