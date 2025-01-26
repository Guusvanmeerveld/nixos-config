{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.qbittorrent;
in {
  options = {
    custom.programs.qbittorrent = {
      enable = lib.mkEnableOption "Enable QBittorrent torrent client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      qbittorrent
    ];
  };
}
