{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.ntfy;
  inherit (dockerConfig) networking;
  inherit (dockerConfig) storage;
in {
  options = {
    custom.virtualisation.docker.ntfy = {
      enable = lib.mkEnableOption "Enable Ntfy notification service";

      externalDomain = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."ntfy" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = {
        BASE_URL = cfg.externalDomain;

        VERSION = "v${pkgs.ntfy.version}";

        DATA_DIR = storage.storageDir + "/ntfy";
      };
    };
  };
}
