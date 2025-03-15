{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.matrix;
  inherit (dockerConfig) networking;
  inherit (dockerConfig) storage;

  createMatrixDir = dirs: lib.concatStringsSep "/" ([storage.storageDir "matrix"] ++ dirs);
in {
  options = {
    custom.virtualisation.docker.matrix = {
      enable = lib.mkEnableOption "Enable Matrix messaging server";

      serverName = lib.mkOption {
        type = lib.types.str;
      };

      secretsFile = lib.mkOption {
        type = lib.types.str;

        description = "A path to a file that contains the env secrets. The ones that are required are `DB_ROOT_PASSWORD` & `DB_PASSWORD`";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users = {
        "matrix" = {
          uid = 4100;

          group = "matrix";

          isSystemUser = true;

          # extraGroups = cfg.extraGroups;
        };
      };

      groups."matrix" = {
        gid = 4100;
      };
    };

    services.docker-compose.projects."matrix" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = [
        {
          SYNAPSE_VERSION = pkgs.matrix-synapse.version;
          SYNAPSE_SERVER_NAME = cfg.serverName;
          SYNAPSE_DATA_DIR = createMatrixDir ["synapse" "data"];
          SYNAPSE_DB_DIR = createMatrixDir ["synapse" "db"];

          SYNAPSE_UID = config.users.users.jellyfin.uid;
          SYNAPSE_GID = config.users.groups.jellyfin.gid;

          SHARED_SECRET_AUTHENTICATOR_FILE = ./shared_secret_authenticator.py;

          WHATSAPP_VERSION = pkgs.mautrix-whatsapp.version;
          WHATSAPP_CONFIG_DIR = createMatrixDir ["whatsapp" "config"];
          WHATSAPP_DB_DIR = createMatrixDir ["whatsapp" "db"];

          EXTERNAL_NETWORK_NAME = networking.defaultNetworkName;
        }
        cfg.secretsFile
      ];
    };
  };
}
