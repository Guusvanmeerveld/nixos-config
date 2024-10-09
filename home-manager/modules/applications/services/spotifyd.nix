{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.service.spotifyd;
in {
  options = {
    custom.applications.services.spotifyd = {
      enable = lib.mkEnableOption "Enable spotifyd streaming client";

      client = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "The devices name as shown to spotify";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.spotifyd = {
      enable = true;

      settings = {
        global = {
          # username = "21xbnszcqkfzil5wflnp7qy4q";
          # password_cmd = "cat ${config.age.secrets.spotifyd.path}";

          device_type = "t_v";
          device_name = cfg.client.name;

          use_mpris = false;

          backend = "pulseaudio";
          # control = "default";
          # mixer = "PCM";

          bitrate = 320;

          initial_volume = "30";

          autoplay = false;

          zeroconf_port = 1234;
        };
      };
    };
  };
}
