{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.twitch-miner;
in {
  options = {
    custom.services.twitch-miner = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Twitch miner service";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/twitch-miner";
        description = "Where the data for the application will be stored";
      };

      username = mkOption {
        type = types.str;
        description = "The username linked to the Twitch account to watch streams for";
      };

      ntfy = {
        url = mkOption {
          type = types.str;
          default = "https://ntfy.sun.guusvanmeerveld.dev";
          description = "The ntfy backend url";
        };

        topic = mkOption {
          type = types.str;
          default = "twitch-miner";
          description = "The ntfy backend url";
        };
      };

      caddy.url = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      virtualisation.oci-containers.containers.twitch-miner = let
        name = "twitch-miner";
        version = "2.0.0";
      in {
        image = "${name}:${version}";
        imageFile = pkgs.dockerTools.pullImage {
          imageName = "rdavidoff/twitch-channel-points-miner-v2";
          imageDigest = "sha256:f160a2e6fd2a558d28c929552fb0992a12a37564a035d9bcec5ffaf76f5fcd05";
          finalImageName = "${name}";
          finalImageTag = "${version}";
          hash = "sha256-jvEaUi9LhSclqncesvXpdPkaUb/uQJHVAveoplchFII=";
        };

        extraOptions = ["--network=host"];

        environment = {
          TWITCH_USERNAME = cfg.username;
          TIMEZONE = config.time.timeZone;
          NTFY_ENDPOINT = "${cfg.ntfy.url}/${cfg.ntfy.topic}";
        };

        volumes = [
          "${cfg.dataDir}/analytics:/usr/src/app/analytics"
          "${cfg.dataDir}/cookies:/usr/src/app/cookies"
          "${cfg.dataDir}/logs:/usr/src/app/logs"
          "${./run.py}:/usr/src/app/run.py:ro"
        ];
      };
    };
}
