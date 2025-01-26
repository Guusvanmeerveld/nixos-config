{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.kdeconnect;
in {
  options = {
    custom.services.kdeconnect = {
      enable = lib.mkEnableOption "Enable Kdeconnect service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.kdeconnect = {
      enable = true;
    };
  };
}
