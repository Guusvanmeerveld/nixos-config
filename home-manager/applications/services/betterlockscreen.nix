{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.betterlockscreen;
in {
  options = {
    custom.applications.services.betterlockscreen = {
      enable = lib.mkEnableOption "Enable Betterlockscreen service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.betterlockscreen = {
      enable = true;
    };
  };
}
