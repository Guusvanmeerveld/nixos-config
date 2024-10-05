{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.qbittorrent;
  storage = dockerConfig.storage;

  createqBittorrentDir = dir: lib.concatStringsSep "/" [storage.storageDir "qbittorrent" dir];
in {
  options = {
    custom.applications.services.docker.qbittorrent = {
      enable = lib.mkEnableOption "Enable qbittorrent client";

      webPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 8080;
      };

      downloadDir = lib.mkOption {
        type = lib.types.str;
        default = createqBittorrentDir "download";
      };

      vpnContainerName = lib.mkOption {
        type = lib.types.str;
        default = config.custom.applications.services.docker.gluetun.containerName;
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users."qbittorrent" = {
        uid = 2000;

        group = "qbittorrent";

        isSystemUser = true;

        extraGroups = cfg.extraGroups;
      };

      groups."qbittorrent" = {
        gid = 2000;
      };
    };

    services.docker-compose.projects."qbittorrent" = {
      file = ./docker-compose.yaml;

      env = {
        CONFIG_DIR = createqBittorrentDir "config";
        DOWNLOAD_DIR = cfg.downloadDir;

        VERSION = pkgs.qbittorrent.version;

        VPN_CONTAINER_NAME = cfg.vpnContainerName;

        PORT = cfg.webPort;

        UID = config.users.users.qbittorrent.uid;
        GID = config.users.groups.qbittorrent.gid;
      };
    };
  };
}
