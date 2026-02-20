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

  # Allow users in same group as jellyfin to access files created by Jellyfin, so programs like Sonarr & Radarr can manage these files.
  systemd.services.jellyfin.serviceConfig = {
    UMask = lib.mkForce "0007";
  };

  services = {
    jellyfin.group = "media";
  };

  # Configure vpn confinement for qBittorrent & Soulseek
  systemd.services = {
    qbittorrent = {
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
      serverConfig = {
        BitTorrent.Session.Port = 10100;
        Preferences.WebUI.Address = "192.168.15.1";

        # Set correct group and permissions for downloaded torrents.
        AutoRun = {
          enabled = true;

          program = ''chmod -R 770 \"%F/\" && chown qbittorrent:media \"%F/\" -R'';
        };
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
