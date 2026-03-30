{
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.vpn-confinement.nixosModules.default
  ];

  users = {
    groups.media = {};

    users =
      {
        media = {
          group = "media";
          isSystemUser = true;
        };
      }
      // (lib.listToAttrs (map (user: {
          name = user;
          value = {
            extraGroups = ["media"];
          };
        }) [
          "radarr"
          "sonarr"
          "bazarr"
          "qbittorrent"
          "cleanuparr"
          "jellyfin"
          "guus"
        ]));
  };

  services = {
    jellyfin.group = "media";
    sonarr.group = "media";
    radarr.group = "media";
    bazarr.group = "media";
  };

  systemd.services = {
    # Allow users in same group as jellyfin to access files created by Jellyfin, so programs like Sonarr & Radarr can manage these files.
    jellyfin.serviceConfig = {
      UMask = lib.mkForce "0007";
    };

    sonarr.serviceConfig = {
      UMask = lib.mkForce "0007";
    };

    radarr.serviceConfig = {
      UMask = lib.mkForce "0007";
    };

    # Configure vpn confinement for qBittorrent & Soulseek

    qbittorrent = {
      serviceConfig = {
        UMask = "0007";
      };

      vpnConfinement = {
        enable = true;
        vpnNamespace = "vpn";
      };
    };

    slskd.vpnConfinement = {
      enable = true;
      vpnNamespace = "vpn";
    };
  };

  # Configure port & listen address for both services
  services = {
    qbittorrent = {
      group = "media";

      serverConfig = {
        BitTorrent.Session.Port = 10100;
        Preferences.WebUI.Address = "192.168.15.1";
      };
    };

    slskd.settings.soulseek.listen_port = 7717;
  };

  # Create VPN namespace
  vpnNamespaces.vpn = {
    # The name is limited to 7 characters

    enable = true;
    wireguardConfigFile = "/secrets/vpn/wgFile";

    accessibleFrom = [
      "127.0.0.0/24"
    ];

    openVPNPorts = [
      {
        port = config.services.qbittorrent.serverConfig.BitTorrent.Session.Port;
        protocol = "both";
      }
      {
        port = config.services.slskd.settings.soulseek.listen_port;
        protocol = "both";
      }
    ];

    portMappings = [
      (let
        qbtPort = config.services.qbittorrent.webuiPort;
      in {
        from = qbtPort;
        to = qbtPort;
      })

      (let
        slskdPort = config.services.slskd.settings.web.port;
      in {
        from = slskdPort;
        to = slskdPort;
      })
    ];
  };
}
