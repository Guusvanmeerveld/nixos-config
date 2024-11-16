{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.waydroid;
in {
  options = {
    custom.applications.waydroid = {
      enable = lib.mkEnableOption "Enable Android virtualization software";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
  };
}
