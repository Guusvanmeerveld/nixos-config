{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.kdeconnect;
in {
  options = {
    custom.applications.services.kdeconnect = {
      enable = lib.mkEnableOption "Enable Kdeconnect service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.kdeconnect = {
      enable = true;
    };
  };
}
