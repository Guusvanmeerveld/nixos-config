{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.nextcloud;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  createNextcloudDir = dir: lib.concatStringsSep "/" [storage.storageDir "nextcloud" dir];
in {
  options = {
    custom.applications.services.docker.nextcloud = {
      enable = lib.mkEnableOption "Enable Nextcloud cloud storage service";

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = createNextcloudDir "data";
      };

      secretsFile = lib.mkOption {
        type = lib.types.path;

        description = "A path to a file that contains the env secrets. The ones that are required are `DB_ROOT_PASSWORD` & `DB_PASSWORD`";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."nextcloud" = {
      file = ./docker-compose.yaml;

      env = [
        {
          DB_DIR = createNextcloudDir "db";
          DATA_DIR = cfg.dataDir;

          VERSION = pkgs.nextcloud29.version;

          DB_NAME = "nextcloud";
          DB_USERNAME = "nextcloud";

          EXTERNAL_NETWORK_NAME = networking.externalNetworkName;
        }
        cfg.secretsFile
      ];
    };
  };
}
