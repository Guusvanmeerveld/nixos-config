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
      enable = lib.mkEnableOption "Enable QBittorrent torrent client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      qbittorrent
    ];
  };
}
