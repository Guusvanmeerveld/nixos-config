{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.gluetun;
  networking = dockerConfig.networking;
in {
  options = {
    custom.applications.services.docker.gluetun = {
      enable = lib.mkEnableOption "Enable Gluetun VPN client";

      containerName = lib.mkOption {
        type = lib.types.str;
        default = "gluetun";
      };

      secretsFile = lib.mkOption {
        type = lib.types.str;

        description = ''
          A path to a file that contains the env secrets.
          The ones that are required are `DB_NAME`, `DB_USERNAME` & `DB_PASSWORD`
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."gluetun" = {
      file = ./docker-compose.yaml;

      env = [
        {
          CONTAINER_NAME = cfg.containerName;

          SECRETS_FILE = cfg.secretsFile;

          DEFAULT_NETWORK_NAME = networking.defaultNetworkName;
        }
      ];
    };
  };
}
