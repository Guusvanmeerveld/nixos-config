{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.nextcloud;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  createNextcloudDir = dir: lib.concatStringsSep "/" [storage.storageDir "nextcloud" dir];
in {
  options = {
    custom.virtualisation.docker.nextcloud = {
      enable = lib.mkEnableOption "Enable Nextcloud cloud storage service";

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = createNextcloudDir "data";
      };

      appDir = lib.mkOption {
        type = lib.types.str;
        default = createNextcloudDir "app";
      };

      secretsFile = lib.mkOption {
        type = lib.types.str;

        description = "A path to a file that contains the env secrets. The ones that are required are `DB_ROOT_PASSWORD` & `DB_PASSWORD`";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users."www-data" = {
        uid = 33;

        group = "www-data";
        isSystemUser = true;
      };

      groups."www-data" = {
        gid = 33;
      };
    };

    services.docker-compose.projects."nextcloud" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = [
        {
          DB_DIR = createNextcloudDir "db";
          DATA_DIR = cfg.dataDir;
          APP_DIR = cfg.appDir;

          VERSION = pkgs.nextcloud29.version;

          DB_NAME = "nextcloud";
          DB_USERNAME = "nextcloud";
        }
        cfg.secretsFile
      ];
    };
  };
}
