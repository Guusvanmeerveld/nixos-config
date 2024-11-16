{
  lib,
  config,
  ...
}: let
  cfg = config.custom.hardware.upower;
in {
  options = {
    custom.hardware.upower = {
      enable = lib.mkEnableOption "Enable Upower, a DBus service that provides power management support to applications.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.upower = {
      enable = true;
    };
  };
}
