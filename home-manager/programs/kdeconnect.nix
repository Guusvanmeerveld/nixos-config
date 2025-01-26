{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.kdeconnect;
in {
  options = {
    custom.programs.kdeconnect = {
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
