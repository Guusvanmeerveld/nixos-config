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

      user = {
        uid = lib.mkOption {
          type = lib.types.int;
          default = config.users.users.qbittorrent.uid;
        };

        gid = lib.mkOption {
          type = lib.types.int;
          default = config.users.groups.qbittorrent.gid;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users."qbittorrent" = {
        uid = 2000;

        group = "qbittorrent";

        isSystemUser = true;
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

        UID = cfg.user.uid;
        GID = cfg.user.gid;
      };
    };
  };
}
