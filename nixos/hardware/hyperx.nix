{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.hyperx;
in {
  options = {
    custom.hardware.hyperx = {
      cloud-flight-s.enable = lib.mkEnableOption "Enable hardware support for the HyperX Cloud Flight S";
    };
  };

  config = {
    environment.systemPackages = lib.optional cfg.cloud-flight-s.enable pkgs.hyperx-cloud-flight-s;
    services.udev.packages = lib.optional cfg.cloud-flight-s.enable pkgs.hyperx-cloud-flight-s;
  };
}
