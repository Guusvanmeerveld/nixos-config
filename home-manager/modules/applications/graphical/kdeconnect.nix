{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.kdeconnect;
in {
  options = {
    custom.applications.graphical.kdeconnect = {
      enable = lib.mkEnableOption "Enable KDE connect service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
