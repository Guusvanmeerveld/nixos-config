{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.jellyfin;
in {
  options = {
    custom.programs.jellyfin = {
      enable = lib.mkEnableOption "Enable Jellyfin client application";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      jellyfin-media-player
    ];
  };
}
