{
  lib,
  config,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.unifi;
  inherit (dockerConfig) networking;
  inherit (dockerConfig) storage;
in {
  options = {
    custom.virtualisation.docker.unifi = {
      enable = lib.mkEnableOption "Enable Unifi network controller";

      user = {
        uid = lib.mkOption {
          type = lib.types.int;
          default = config.users.users.unifi.uid;
        };

        gid = lib.mkOption {
          type = lib.types.int;
          default = config.users.groups.unifi.gid;
        };
      };

      secretsFile = lib.mkOption {
        type = lib.types.str;

        description = "A path to a file that contains the env secrets. The ones that are required are `DB_ROOT_PASS`, `DB_USER`, `DB_PASS`, `DB_NAME`";
      };

      openFirewall = lib.mkEnableOption "Open default ports";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = lib.optionals cfg.openFirewall [8080 8443];
      allowedUDPPorts = lib.optionals cfg.openFirewall [3478 10001];
    };

    users = {
      users."unifi" = {
        uid = 3400;

        group = "unifi";
        isSystemUser = true;
      };

      groups."unifi" = {
        gid = 3400;
      };
    };

    services.docker-compose.projects."unifi" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = [
        cfg.secretsFile
        {
          UID = cfg.user.uid;
          GID = cfg.user.gid;

          CONFIG_DIR = storage.storageDir + "/unifi/app/config";
          DB_DATA_DIR = storage.storageDir + "/unifi/db/data";

          DB_INIT_SCRIPT = "${./init-mongo.sh}";
        }
      ];
    };
  };
}
