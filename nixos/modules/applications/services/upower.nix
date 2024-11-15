{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.upower;
in {
  options = {
    custom.applications.services.upower = {
      enable = lib.mkEnableOption "Enable Upower, a DBus service that provides power management support to applications.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.upower = {
      enable = true;
    };
  };
}
