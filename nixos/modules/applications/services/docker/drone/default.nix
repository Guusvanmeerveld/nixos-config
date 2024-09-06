{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.drone;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;
in {
  options = {
    custom.applications.services.docker.drone = {
      enable = lib.mkEnableOption "Enable drone git provider";

      externalDomain = lib.mkOption {
        type = lib.types.str;
        description = "The domain this instance can be reached from by the internet";
      };

      gitea = {
        externalDomain = lib.mkOption {
          type = lib.types.str;
        };
      };

      adminUsername = lib.mkOption {
        type = lib.types.str;
        description = "The username for the default admin that is autocreated";
      };

      secretsFile = lib.mkOption {
        type = lib.types.path;

        description = "A path to a file that contains the env secrets. The ones that are required are `DB_ROOT_PASSWORD` & `DB_PASSWORD`";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."drone" = {
      file = ./docker-compose.yaml;

      env = [
        cfg.secretsFile
        {
          VERSION = pkgs.drone.version;

          DATA_DIR = storage.storageDir + "/drone";

          ADMIN_USERNAME = cfg.adminUsername;

          EXTERNAL_DOMAIN = cfg.externalDomain;
          GITEA_EXTERNAL_DOMAIN = cfg.gitea.externalDomain;

          EXTERNAL_NETWORK_NAME = networking.externalNetworkName;
        }
      ];
    };
  };
}
