{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.input.logitech;
in {
  options = {
    custom.hardware.input.logitech = {
      enable = lib.mkEnableOption "Enable Logitech hardware support";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.logitech.wireless = {
      enable = true;

      enableGraphical = true;
    };
  };
}
