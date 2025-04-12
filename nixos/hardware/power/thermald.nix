{
  config,
  lib,
  ...
}: let
  cfg = config.custom.hardware.power.thermald;
in {
  options = {
    custom.hardware.power.thermald.enable = lib.mkEnableOption "Enable Thermald thermal management for Intel CPUs";
  };

  config = lib.mkIf cfg.enable {
    services.thermald.enable = true;
  };
}
