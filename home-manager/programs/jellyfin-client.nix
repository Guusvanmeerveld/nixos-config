{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.jellyfin-client;
in {
  options = {
    custom.programs.jellyfin-client = {
      enable = lib.mkEnableOption "Enable Jellyfin client application";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin-mpv-shim = {
      enable = true;
    };
  };
}
