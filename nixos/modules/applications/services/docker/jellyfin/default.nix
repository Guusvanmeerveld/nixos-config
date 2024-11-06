{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.jellyfin;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  createJellyfinDir = dir: lib.concatStringsSep "/" [storage.storageDir "jellyfin" dir];
in {
  options = {
    custom.applications.services.docker.jellyfin = {
      enable = lib.mkEnableOption "Enable jellyfin media streaming service";

      mediaDir = lib.mkOption {
        type = lib.types.str;
        default = createJellyfinDir "media";
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users."jellyfin" = {
        uid = 2001;

        group = "jellyfin";

        isSystemUser = true;

        extraGroups = cfg.extraGroups;
      };

      groups."jellyfin" = {
        gid = 2001;
      };
    };

    services.docker-compose.projects."jellyfin" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = {
        LOGS_DIR = createJellyfinDir "logs";
        CONFIG_DIR = createJellyfinDir "config";
        TRANSCODES_DIR = createJellyfinDir "transcodes";
        CACHE_DIR = createJellyfinDir "cache";
        MEDIA_DIR = cfg.mediaDir;

        HOSTNAME = config.networking.hostName;

        VERSION = pkgs.jellyfin.version;

        VIDEO_GROUP = "998";
        UID = config.users.users.jellyfin.uid;
        GID = config.users.groups.jellyfin.gid;
      };
    };
  };
}
