{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.gitea;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  createGiteaDir = dir: lib.concatStringsSep "/" [storage.storageDir "gitea" dir];
in {
  options = {
    custom.applications.services.docker.gitea = {
      enable = lib.mkEnableOption "Enable Gitea git provider";

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = createGiteaDir "data";
      };

      sshPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 4444;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users."gitea" = {
        uid = 1200;

        group = "gitea";
        isSystemUser = true;

        createHome = true;
        home = "/home/gitea/";
      };

      groups."gitea" = {
        gid = 1200;
      };
    };

    services.docker-compose.projects."gitea" = {
      file = ./docker-compose.yaml;

      env = [
        ./.env
        {
          VERSION = pkgs.forgejo.version;

          HOSTNAME = config.networking.hostName;

          DATA_DIR = cfg.dataDir;
          DB_DIR = createGiteaDir "db";

          SSH_PORT = cfg.sshPort;
          USER_SSH_DIR = config.users.users.gitea.home + ".ssh";

          UID = config.users.users.gitea.uid;
          GID = config.users.groups.gitea.gid;

          INTERNAL_NETWORK_NAME = networking.internalNetworkName;
          EXTERNAL_NETWORK_NAME = networking.externalNetworkName;
        }
      ];
    };
  };
}
