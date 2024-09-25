{
  lib,
  config,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.immich;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  createImmichDir = dir: lib.concatStringsSep "/" [storage.storageDir "immich" dir];
in {
  options = {
    custom.applications.services.docker.immich = {
      enable = lib.mkEnableOption "Enable immich media streaming service";

      uploadDir = lib.mkOption {
        type = lib.types.str;
        default = createImmichDir "upload";
      };

      secretsFile = lib.mkOption {
        type = lib.types.str;

        description = ''
          A path to a file that contains the env secrets.
          The ones that are required are `DB_PASSWORD`
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."immich" = {
      file = ./docker-compose.yaml;

      env = [
        cfg.secretsFile
        {
          IMMICH_VERSION = "release";

          UPLOAD_DIR = cfg.uploadDir;
          CACHE_DIR = createImmichDir "cache";
          DB_DIR = createImmichDir "db";

          SECRETS_FILE = cfg.secretsFile;

          DB_HOSTNAME = "immich-db";
          DB_USERNAME = "immich";
          DB_DATABASE_NAME = "immich";

          REDIS_HOSTNAME = "immich-redis";

          DEFAULT_NETWORK_NAME = networking.defaultNetworkName;
        }
      ];
    };
  };
}