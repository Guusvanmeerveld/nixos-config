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
    services.docker-compose.networks."${cfg.defaultNetworkName}" = {
    };
  };
}
