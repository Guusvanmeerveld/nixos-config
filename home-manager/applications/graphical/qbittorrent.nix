{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.qbittorrent;
in {
  options = {
    custom.applications.graphical.qbittorrent = {
      enable = lib.mkEnableOption "Enable Cantata MPD client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      qbittorrent-qt5
    ];
  };
}
