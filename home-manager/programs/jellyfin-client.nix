{
  lib,
  config,
  pkgs,
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
    home.packages = with pkgs; [jellyfin-desktop];
  };
}
