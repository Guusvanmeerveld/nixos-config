{config, ...}: {
  config = {
    services.samba = let
      hostname = config.networking.hostName;

      baseConfig = {
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    in {
      enable = true;
      openFirewall = true;

      # extraConfig = ''
      #   workgroup = WORKGROUP
      #   server string = ${hostname}
      #   netbios name = ${hostname}
      #   security = user

      #   # use sendfile = yes
      #   # max protocol = smb2

      #   # note: localhost is the ipv6 localhost ::1
      #   hosts allow = 192.168.2. 127.0.0.1 localhost
      #   hosts deny = 0.0.0.0/0

      #   guest account = nobody
      #   map to guest = bad user
      # '';

      settings = {
        global = {
          "invalid users" = [
            "root"
          ];

          security = "user";

          "hosts allow" = ["192.168.2." "127.0.0.1" "localhost"];
          "hosts deny" = ["0.0.0.0/0"];
        };

        iso =
          {
            path = "/mnt/data/iso";
          }
          // baseConfig;

        games =
          {
            path = "/mnt/data/games";
          }
          // baseConfig;

        media =
          {
            path = "/mnt/data/media";
          }
          // baseConfig;

        nextcloud =
          {
            path = "/mnt/data/apps/nextcloud";
          }
          // baseConfig;

        gitea =
          {
            path = "/mnt/data/apps/gitea";
          }
          // baseConfig;

        syncthing =
          {
            path = "/mnt/data/apps/syncthing";
          }
          // baseConfig;

        immich =
          {
            path = "/mnt/data/apps/immich";
          }
          // baseConfig;
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
