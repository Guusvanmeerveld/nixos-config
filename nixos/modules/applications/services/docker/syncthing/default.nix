{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.syncthing;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;
in {
  options = {
    custom.applications.services.docker.syncthing = {
      enable = lib.mkEnableOption "Enable Syncthing docker service";

      syncDir = lib.mkOption {
        type = lib.types.str;
        default = storage.storageDir + "/syncthing/sync";
      };

      configDir = lib.mkOption {
        type = lib.types.str;
        default = storage.storageDir + "/syncthing/config";
      };

      fileTransferPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 22000;
      };

      discoveryPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 21027;
      };

      openFirewall = lib.mkEnableOption "Open needed ports in firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [cfg.fileTransferPort cfg.discoveryPort];

    users = {
      users."syncthing" = {
        uid = 1300;

        group = "syncthing";
        isSystemUser = true;
      };

      groups."syncthing" = {
        gid = 1300;
      };
    };

    services.docker-compose.projects."syncthing" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = {
        HOSTNAME = config.networking.hostName;

        CONFIG_DIR = cfg.configDir;
        SYNC_DIR = cfg.syncDir;

        UID = config.users.users.syncthing.uid;
        GID = config.users.groups.syncthing.gid;

        VERSION = pkgs.syncthing.version;

        FILE_TRANSFER_PORT = cfg.fileTransferPort;
        DISCOVERY_PORT = cfg.discoveryPort;
      };
    };
  };
}
