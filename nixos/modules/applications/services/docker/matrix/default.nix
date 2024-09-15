{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.matrix;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  createMatrixDir = dir: lib.concatStringsSep "/" [storage.storageDir "matrix" dir];
in {
  options = {
    custom.applications.services.docker.matrix = {
      enable = lib.mkEnableOption "Enable Nextcloud cloud storage service";

      secretsFile = lib.mkOption {
        type = lib.types.str;

        description = "A path to a file that contains the env secrets. The ones that are required are `DB_ROOT_PASSWORD` & `DB_PASSWORD`";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."matrix" = {
      file = ./docker-compose.yaml;

      env = [
        {
          SYNAPSE_VERSION = pkgs.matrix-synapse.version;
          WHATSAPP_VERSION = pkgs.mautrix-whatsapp.version;

          EXTERNAL_NETWORK_NAME = networking.externalNetworkName;
        }
        cfg.secretsFile
      ];
    };
  };
}
