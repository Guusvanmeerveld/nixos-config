{
  lib,
  config,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;
  cfg = config.custom.applications.services.docker.networking;
in {
  options = {
    custom.applications.services.docker.networking = {
      defaultNetworkName = lib.mkOption {
        type = lib.types.str;
        default = "internet";
      };

      internalNetworkName = lib.mkOption {
        type = lib.types.str;
        default = "internal";
      };
    };
  };

  config = lib.mkIf dockerConfig.enable {
    # Create default network
    services.docker-compose = {
      networks."${cfg.defaultNetworkName}" = {
        subnet = ["172.18.0.0/16"];
      };

      globalEnv = {
        DEFAULT_NETWORK_NAME = cfg.defaultNetworkName;
        INTERNAL_NETWORK_NAME = cfg.internalNetworkName;
      };
    };
  };
}
