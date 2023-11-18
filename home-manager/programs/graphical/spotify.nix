{ config, pkgs, ... }:

let
  username = "21xbnszcqkfzil5wflnp7qy4q";
in
{
  home.packages = with pkgs;
    [ spotifywm ];

  services.spotifyd = {
    enable = true;

    settings = {
      global = {
        username = username;
        password_cmd = "cat ${config.age.secrets.spotifyd.path}";

        device_name = "desktop";

        use_mpris = true;

        dbus_type = "session";

        initial_volume = "50";
        backend = "alsa";
      };
    };
  };
}
