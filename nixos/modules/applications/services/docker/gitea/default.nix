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

      gitDataDir = lib.mkOption {
        type = lib.types.str;
        default = createGiteaDir "git";

        description = "Path to the directory that the git data will be stored on";
      };

      sshPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 4444;
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
        cfg.secretsFile
        {
          VERSION = pkgs.forgejo.version;

          HOSTNAME = config.networking.hostName;

          DATA_DIR = cfg.dataDir;
          GIT_DATA_DIR = cfg.gitDataDir;
          DB_DIR = createGiteaDir "db";

          SSH_PORT = cfg.sshPort;
          USER_SSH_DIR = config.users.users.gitea.home + ".ssh";

          UID = config.users.users.gitea.uid;
          GID = config.users.groups.gitea.gid;

          DEFAULT_NETWORK_NAME = networking.defaultNetworkName;
        }
      ];
    };
  };
}
