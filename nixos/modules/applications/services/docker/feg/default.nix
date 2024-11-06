{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.feg;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;
in {
  options = {
    custom.applications.services.docker."feg" = {
      enable = lib.mkEnableOption "Enable Free Epic Games service";

      secretsFile = lib.mkOption {
        type = lib.types.str;

        description = ''
          A path to a file that contains the env secrets.
          The ones that are required are `SMTP_HOST, EMAIL_SENDER_ADDRESS, EMAIL_SENDER_NAME, EMAIL_RECIPIENT_ADDRESS, SMTP_USERNAME & SMTP_PASSWORD`
        '';
      };

      epicGamesEmail = lib.mkOption {
        type = lib.types.str;
        description = "The email address of the Epic Games account";
      };

      externalDomain = lib.mkOption {
        type = lib.types.str;
        description = "The domain this instance can be reached from by the internet";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."feg" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = [
        {
          SECRETS_FILE = cfg.secretsFile;

          EG_EMAIL = cfg.epicGamesEmail;

          CONFIG_DIR = storage.storageDir + "/feg/config";

          EXTERNAL_DOMAIN = cfg.externalDomain;
        }
      ];
    };
  };
}
