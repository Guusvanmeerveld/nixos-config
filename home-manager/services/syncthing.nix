{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.syncthing;
in {
  options = {
    custom.services.syncthing = {
      enable = lib.mkEnableOption "Enable Syncthing file synchronize";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      # tray = {
      #   enable = true;
      # };
    };
  };
}
