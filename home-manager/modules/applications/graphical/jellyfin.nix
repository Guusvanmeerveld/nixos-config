{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.jellyfin;
in {
  options = {
    custom.applications.graphical.jellyfin = {
      enable = lib.mkEnableOption "Enable Jellyfin client application";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      jellyfin-media-player
    ];
  };
}
