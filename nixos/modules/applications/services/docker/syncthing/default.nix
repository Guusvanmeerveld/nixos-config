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
        default = storage.storageDir + "/syncthing";
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

    services.docker-compose.projects."syncthing" = {
      file = ./docker-compose.yaml;

      env = {
        HOSTNAME = config.networking.hostName;

        INTERNAL_NETWORK_NAME = networking.internalNetworkName;

        CONFIG_DIR = cfg.syncDir;

        VERSION = pkgs.syncthing.version;

        FILE_TRANSFER_PORT = cfg.fileTransferPort;
        DISCOVERY_PORT = cfg.discoveryPort;
      };
    };
  };
}
