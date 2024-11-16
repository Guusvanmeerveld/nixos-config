{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.vaultwarden;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;
in {
  options = {
    custom.applications.services.docker.vaultwarden = {
      enable = lib.mkEnableOption "Enable Vaultwarden encrypted password store";

      externalDomain = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users."vaultwarden" = {
        uid = 2500;

        group = "vaultwarden";
        isSystemUser = true;
      };

      groups."vaultwarden" = {
        gid = 2500;
      };
    };

    services.docker-compose.projects."vaultwarden" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = {
        HOSTNAME = config.networking.hostName;

        DATA_DIR = storage.storageDir + "/vaultwarden/data";
        DB_DATA_DIR = storage.storageDir + "/vaultwarden/db/data";

        UID = config.users.users.vaultwarden.uid;
        GID = config.users.groups.vaultwarden.gid;

        VERSION = pkgs.vaultwarden.version;
      };
    };
  };
}
