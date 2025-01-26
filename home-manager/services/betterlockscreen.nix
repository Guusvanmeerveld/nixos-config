{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.betterlockscreen;
in {
  options = {
    custom.services.betterlockscreen = {
      enable = lib.mkEnableOption "Enable Betterlockscreen service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.betterlockscreen = {
      enable = true;
    };
  };
}
