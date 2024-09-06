{...}: {
  config = {
    services.samba = {
      enable = true;
      openFirewall = true;

      securityType = "user";

      extraConfig = ''
        workgroup = WORKGROUP
        server string = orchid
        netbios name = orchid
        security = user

        # use sendfile = yes
        # max protocol = smb2

        # note: localhost is the ipv6 localhost ::1
        hosts allow = 192.168.2. 127.0.0.1 localhost
        hosts deny = 0.0.0.0/0

        guest account = nobody
        map to guest = bad user
      '';

      shares = {
        iso = {
          path = "/mnt/data/iso";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
        };

        games = {
          path = "/mnt/data/games";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
        };

        media = {
          path = "/mnt/data/media";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
        };

        apps = {
          path = "/mnt/data/apps";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
