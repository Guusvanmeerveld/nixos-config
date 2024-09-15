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
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."jellyfin" = {
      file = ./docker-compose.yaml;

      env = {
        LOGS_DIR = createJellyfinDir "logs";
        CONFIG_DIR = createJellyfinDir "config";
        TRANSCODES_DIR = createJellyfinDir "transcodes";
        CACHE_DIR = createJellyfinDir "cache";
        MEDIA_DIR = cfg.mediaDir;

        HOSTNAME = config.networking.hostName;

        VERSION = pkgs.jellyfin.version;

        VIDEO_GROUP = "998";

        DEFAULT_NETWORK_NAME = networking.defaultNetworkName;
      };
    };
  };
}
