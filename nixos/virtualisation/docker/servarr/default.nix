{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.servarr;
  inherit (dockerConfig) storage;
  inherit (dockerConfig) networking;

  createServarrDir = dir: lib.concatStringsSep "/" ([storage.storageDir "servarr"] ++ dir);

  services = ["bazarr" "prowlarr" "radarr" "sonarr"];
in {
  options = {
    custom.virtualisation.docker.servarr = {
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
        default = config.custom.virtualisation.docker.gluetun.containerName;
      };

      user = {
        gid = lib.mkOption {
          type = lib.types.int;
        };
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

        networks = [networking.defaultNetworkName];

        env = {
          CONFIG_DIR = createServarrDir ["bazarr" "config"];
          TV_DIR = cfg.tvDir;
          MOVIE_DIR = cfg.movieDir;

          VERSION = pkgs.bazarr.version;

          PORT = toString cfg.bazarr.webPort;

          UID = config.users.users.bazarr.uid;
          GID = cfg.user.gid;
        };
      };

      "prowlarr" = lib.mkIf cfg.prowlarr.enable {
        file = ./prowlarr/docker-compose.yaml;

        networks = [networking.defaultNetworkName];

        env = {
          CONFIG_DIR = createServarrDir ["prowlarr" "config"];

          VERSION = "version-${pkgs.unstable.prowlarr.version}";

          UID = config.users.users.prowlarr.uid;
          GID = cfg.user.gid;
        };
      };

      "radarr" = lib.mkIf cfg.radarr.enable {
        file = ./radarr/docker-compose.yaml;

        networks = [networking.defaultNetworkName];

        env = {
          CONFIG_DIR = createServarrDir ["radarr" "config"];
          SCRIPTS_DIR = createServarrDir ["radarr" "scripts"];
          MOVIE_DIR = cfg.movieDir;
          DOWNLOAD_DIR = cfg.downloadDir;

          VERSION = "version-${pkgs.radarr.version}";

          UID = config.users.users.radarr.uid;
          GID = cfg.user.gid;
        };
      };

      "sonarr" = lib.mkIf cfg.sonarr.enable {
        file = ./sonarr/docker-compose.yaml;

        networks = [networking.defaultNetworkName];

        env = {
          CONFIG_DIR = createServarrDir ["sonarr" "config"];
          SCRIPTS_DIR = createServarrDir ["sonarr" "scripts"];
          TV_DIR = cfg.tvDir;
          DOWNLOAD_DIR = cfg.downloadDir;

          VERSION = "version-${pkgs.sonarr.version}";

          UID = config.users.users.sonarr.uid;
          GID = cfg.user.gid;
        };
      };
    };
  };
}
