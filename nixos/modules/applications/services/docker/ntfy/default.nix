{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.ntfy;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;
in {
  options = {
    custom.applications.services.docker.ntfy = {
      enable = lib.mkEnableOption "Enable Ntfy notification service";

      baseUrl = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."ntfy" = {
      file = ./docker-compose.yaml;

      env = {
        BASE_URL = cfg.baseUrl;

        VERSION = "v${pkgs.ntfy.version}";

        DATA_DIR = storage.storageDir + "/ntfy";

        EXTERNAL_NETWORK_NAME = networking.externalNetworkName;
      };
    };
  };
}
