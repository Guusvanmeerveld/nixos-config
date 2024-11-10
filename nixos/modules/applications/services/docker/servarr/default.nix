{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.servarr;
  storage = dockerConfig.storage;

  createServarrDir = dir: lib.concatStringsSep "/" ([storage.storageDir "servarr"] ++ dir);

  services = ["bazarr" "prowlarr" "radarr" "sonarr"];
in {
  options = {
    custom.applications.services.docker.servarr = {
      enable = lib.mkEnableOption "Enable Servarr application suite";

      downloadDir = lib.mkOption {
        type = lib.types.str;
        default = createServarrDir ["download"];
      };

      tvDir = lib.mkOption {
        type = lib.types.str;
        default = createServarrDir ["tv"];
      };

      movieDir = lib.mkOption {
        type = lib.types.str;
        default = createServarrDir ["movies"];
      };

      vpnContainerName = lib.mkOption {
        type = lib.types.str;
        default = config.custom.applications.services.docker.gluetun.containerName;
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      bazarr = {
        enable = lib.mkEnableOption "Enable Bazarr subtitle manager";

        webPort = lib.mkOption {
          type = lib.types.ints.u16;
          default = 6767;
        };
      };

      prowlarr = {
        enable = lib.mkEnableOption "Enable Prowlarr indexer manager";
      };

      radarr = {
        enable = lib.mkEnableOption "Enable Radarr movie manager";
      };

      sonarr = {
        enable = lib.mkEnableOption "Enable Sonarr tv show manager";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users = builtins.listToAttrs (lib.imap0 (i: service: {
          name = service;
          value = {
            uid = 2010 + i;

            group = service;

            isSystemUser = true;

            extraGroups = cfg.extraGroups;
          };
        })
        services);

      groups = builtins.listToAttrs (lib.imap0 (i: service: {
          name = service;
          value = {
            gid = 2010 + i;
          };
        })
        services);
    };

    services.docker-compose.projects = {
      "bazarr" = lib.mkIf cfg.bazarr.enable {
        file = ./bazarr/docker-compose.yaml;

        env = {
          CONFIG_DIR = createServarrDir ["bazarr" "config"];
          TV_DIR = cfg.tvDir;
          MOVIE_DIR = cfg.movieDir;

          VERSION = pkgs.bazarr.version;

          VPN_CONTAINER_NAME = cfg.vpnContainerName;

          PORT = toString cfg.bazarr.webPort;

          UID = config.users.users.bazarr.uid;
          GID = config.users.groups.bazarr.gid;
        };
      };

      "prowlarr" = lib.mkIf cfg.prowlarr.enable {
        file = ./prowlarr/docker-compose.yaml;

        env = {
          CONFIG_DIR = createServarrDir ["prowlarr" "config"];

          VERSION = "version-${pkgs.prowlarr.version}";

          VPN_CONTAINER_NAME = cfg.vpnContainerName;

          UID = config.users.users.prowlarr.uid;
          GID = config.users.groups.prowlarr.gid;
        };
      };

      "radarr" = lib.mkIf cfg.radarr.enable {
        file = ./radarr/docker-compose.yaml;

        env = {
          CONFIG_DIR = createServarrDir ["radarr" "config"];
          SCRIPTS_DIR = createServarrDir ["radarr" "scripts"];
          MOVIE_DIR = cfg.movieDir;
          DOWNLOAD_DIR = cfg.downloadDir;

          VERSION = "version-${pkgs.radarr.version}";

          VPN_CONTAINER_NAME = cfg.vpnContainerName;

          UID = config.users.users.radarr.uid;
          GID = config.users.groups.radarr.gid;
        };
      };

      "sonarr" = lib.mkIf cfg.sonarr.enable {
        file = ./sonarr/docker-compose.yaml;

        env = {
          CONFIG_DIR = createServarrDir ["sonarr" "config"];
          SCRIPTS_DIR = createServarrDir ["sonarr" "scripts"];
          TV_DIR = cfg.tvDir;
          DOWNLOAD_DIR = cfg.downloadDir;

          VERSION = "version-${pkgs.sonarr.version}";

          VPN_CONTAINER_NAME = cfg.vpnContainerName;

          UID = config.users.users.sonarr.uid;
          GID = config.users.groups.sonarr.gid;
        };
      };
    };
  };
}
