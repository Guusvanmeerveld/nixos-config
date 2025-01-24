{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.openrgb;
in {
  options = {
    custom.hardware.openrgb.enable = lib.mkEnableOption "Enable OpenRGB application";
  };

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };
  };
}
