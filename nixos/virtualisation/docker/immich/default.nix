{
  lib,
  config,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.immich;
  inherit (dockerConfig) networking;
  inherit (dockerConfig) storage;

  createImmichDir = dir: lib.concatStringsSep "/" [storage.storageDir "immich" dir];
in {
  options = {
    custom.virtualisation.docker.immich = {
      enable = lib.mkEnableOption "Enable Immich photo and video library";

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
    users = {
      users."immich" = {
        uid = 1600;

        group = "immich";
        isSystemUser = true;
      };

      groups."immich" = {
        gid = 1600;
      };
    };

    services.docker-compose.projects."immich" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = [
        cfg.secretsFile
        {
          IMMICH_VERSION = "release";

          UPLOAD_DIR = cfg.uploadDir;
          CACHE_DIR = createImmichDir "cache";
          DB_DIR = createImmichDir "db";

          SECRETS_FILE = cfg.secretsFile;

          UID = config.users.users.immich.uid;
          GID = config.users.groups.immich.gid;

          DB_HOSTNAME = "immich-db";
          DB_USERNAME = "immich";
          DB_DATABASE_NAME = "immich";

          REDIS_HOSTNAME = "immich-redis";
        }
      ];
    };
  };
}
