{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical;
in {
  options = {
    custom.applications.graphical.openrgb.enable = lib.mkEnableOption "Enable openrgb application";
  };

  config = lib.mkIf cfg.openrgb.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };
  };
}
