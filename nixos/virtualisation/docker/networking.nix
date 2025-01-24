{
  lib,
  config,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;
  cfg = config.custom.virtualisation.docker.networking;
in {
  options = {
    custom.virtualisation.docker.networking = {
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
