{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.jellyfin;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  createJellyfinDir = dir: lib.concatStringsSep "/" [storage.storageDir "jellyfin" dir];
in {
  options = {
    custom.virtualisation.docker.jellyfin = {
      enable = lib.mkEnableOption "Enable jellyfin media streaming service";

      mediaDir = lib.mkOption {
        type = lib.types.str;
        default = createJellyfinDir "media";
      };

      user = {
        uid = lib.mkOption {
          type = lib.types.int;
          default = config.users.users.jellyfin.uid;
        };

        gid = lib.mkOption {
          type = lib.types.int;
          default = config.users.groups.jellyfin.gid;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users."jellyfin" = {
        uid = 2001;

        group = "jellyfin";

        isSystemUser = true;

        extraGroups = ["video"];
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

        UID = cfg.user.uid;
        GID = cfg.user.gid;
      };
    };
  };
}
