{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.twitch-miner;
  inherit (dockerConfig) storage;

  runFile = pkgs.writeText "twitch-miner-run" ''
    from TwitchChannelPointsMiner import TwitchChannelPointsMiner
    from TwitchChannelPointsMiner.classes.Settings import FollowersOrder, Priority
    from TwitchChannelPointsMiner.classes.entities.Streamer import Streamer, StreamerSettings

    twitch_miner = TwitchChannelPointsMiner("${cfg.username}", priority=[
          Priority.STREAK, # - We want first of all to catch all watch streak from all streamers
          Priority.DROPS,  # - When we don't have anymore watch streak to catch, wait until all drops are collected over the streamers
          Priority.ORDER   # - When we have all of the drops claimed and no watch-streak available, use the order priority (POINTS_ASCENDING, POINTS_DESCEDING)
        ],
        streamer_settings=StreamerSettings(make_predictions=False)
        )

    twitch_miner.mine(followers=True, followers_order=FollowersOrder.ASC)
  '';
in {
  options = {
    custom.virtualisation.docker.twitch-miner = {
      enable = lib.mkEnableOption "Enable Twitch channel points miner service";

      username = lib.mkOption {
        type = lib.types.str;
        description = "The twitch username to login to";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."twitch-miner" = {
      file = ./docker-compose.yaml;

      env = {
        RUN_FILE = toString runFile;
        DATA_DIR = storage.storageDir + "/twitch-miner";
      };
    };
  };
}
