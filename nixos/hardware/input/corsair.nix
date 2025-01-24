{
  config,
  lib,
  ...
}: let
  cfg = config.custom.hardware.input.corsair;
in {
  options = {
    custom.hardware.input.corsair.enable = lib.mkEnableOption "Enable Corsair keyboard support application";
  };

  config = lib.mkIf cfg.enable {
    hardware.ckb-next.enable = true;
  };
}
