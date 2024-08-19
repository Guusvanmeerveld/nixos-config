{ config, ... }: {
  config = {
    services.spotifyd = {
      enable = true;
      
      settings = {
        global = {
          username = "21xbnszcqkfzil5wflnp7qy4q";

          password_cmd = "cat ${config.age.secrets.spotifyd.path}";

          device_type = "t_v";
          device_name = "Raspberry Pi";

          use_mpris = true;
          dbus_type = "session";

          backend = "alsa";
          control = "default"; 
          mixer = "PCM";

          initial_volume = "30";

          autoplay = false;

          zeroconf_port = 1234;
        };
      };
    };
  };
}