# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    inputs.vpn-confinement.nixosModules.default
  ];

  fileSystems = {
    "/" = {
      device = "root/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "root/nix";
      fsType = "zfs";
    };

    "/var" = {
      device = "root/var";
      fsType = "zfs";
    };

    "/home" = {
      device = "root/home";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

    # "/mnt/data" = {
    #   device = "zpool/data";
    #   fsType = "zfs";
    # };

    "/mnt/bigdata/restic" = {
      device = "bigdata/restic";
      fsType = "zfs";
    };

    "/mnt/bigdata/syncthing" = {
      device = "bigdata/syncthing";
      fsType = "zfs";
    };

    "/mnt/bigdata/immich" = {
      device = "bigdata/immich";
      fsType = "zfs";
    };

    "/mnt/bigdata/media" = {
      device = "bigdata/media";
      fsType = "zfs";
    };
  };

  boot = {
    tmp.cleanOnBoot = true;

    loader = {
      systemd-boot.enable = true;
      timeout = 0;
    };

    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  hardware.graphics = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [radeontop nvtopPackages.amd];

  networking = {
    hostName = "sunflower";
    hostId = "deadb33f";
    networkmanager.enable = true;
  };

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
          "lidarr"
          "qbittorrent"
          "jellyfin"
        ]));
  };

  services.qbittorrent-nox.address = "192.168.15.1";

  services.slskd.settings.soulseek = {
    listen_port = 7717;
  };

  systemd.services = {
    qbittorrent-nox.vpnConfinement = {
      enable = true;
      vpnNamespace = "vpn";
    };

    slskd.vpnConfinement = {
      enable = true;
      vpnNamespace = "vpn";
    };
  };

  vpnNamespaces.vpn = {
    # The name is limited to 7 characters

    enable = true;
    wireguardConfigFile = "/secrets/vpn/wgFile";

    accessibleFrom = [
      "127.0.0.0/24"
    ];

    openVPNPorts = [
      {
        port = 10100;
        protocol = "both";
      }
      {
        port = config.services.slskd.settings.soulseek.listen_port;
        protocol = "both";
      }
    ];

    portMappings = [
      (let
        qbtPort = config.services.qbittorrent-nox.webUIPort;
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

  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };

      ssh.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKIdNGCw0MURAoLliBBn3+LGGXZu17yNYUuOAMDHXoqj guus@thuisthuis"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxp38hLC2UUaKt7wkiqSHUHI9FxrY8gHJTO2sAElZID guus@framework-13"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZ3RNokgR4jcvxvCHtMS5zd8BPPNPb+7tZKBVz4y6SU guus@desktop"
      ];
    };

    hardware.power.thermald.enable = true;

    certificates.enable = true;

    fs.zfs.enable = true;

    networking.wireguard = {
      enable = true;

      networks = {
        "garden" = {
          enable = true;
          keepAlive = true;
        };
      };
    };

    services = {
      openssh.enable = true;
      autoUpgrade.enable = true;

      caddy = {
        enable = true;

        ca = {
          enable = true;

          cert = "${../../nixos/certificates/sunflower.crt}";
          key = "/secrets/caddy/ca/root.key";
        };

        openFirewall = true;
      };

      jellyfin = {
        enable = true;

        port = 8000;

        caddy.url = "http://jellyfin.sun";
      };

      jellyseerr = {
        enable = true;

        port = 8001;

        caddy.url = "https://jellyseerr.sun";
      };

      uptime-kuma = {
        enable = true;

        port = 8002;

        caddy.url = "https://uptime.sun";
      };

      homeassistant = {
        enable = true;

        port = 8003;

        ntfy.url = "https://ntfy.sun";

        caddy.url = "https://homeassistant.sun";
      };

      ntfy = {
        enable = true;

        port = 8004;

        caddy.url = "https://ntfy.sun";
      };

      miniflux = {
        enable = true;

        port = 8005;

        adminCredentialsFile = "/secrets/miniflux/adminCredentials";

        caddy.url = "https://miniflux.sun";
      };

      vaultwarden = {
        enable = true;

        port = 8006;

        environmentFile = "/secrets/vaultwarden/environmentFile";

        caddy.url = "https://bitwarden.sun";
      };

      # traccar = {
      #   enable = true;

      # port = 8007;

      #   caddy.url = "https://traccar.sun";
      # };

      radicale = {
        enable = true;

        port = 8008;

        htpasswdFile = "/secrets/radicale/htpasswdFile";

        caddy.url = "https://radicale.sun";
      };

      atuin = {
        enable = true;

        port = 8009;

        caddy.url = "https://atuin.sun";
      };

      unifi = {
        enable = true;

        port = 8443;

        openFirewall = true;

        caddy.url = "https://unifi";
      };

      free-epic-games = {
        enable = true;

        port = 8011;

        email = "mail@guusvanmeerveld.dev";

        ntfy.url = "http://0.0.0.0:${toString config.custom.services.ntfy.port}";

        caddy.url = "http://free-epic-games.sun";
      };

      twitch-miner = {
        enable = true;
        username = "guusvanmeerveld";

        ntfy.url = "http://localhost:${toString config.custom.services.ntfy.port}";
      };

      mealie = {
        enable = true;

        port = 8012;

        caddy.url = "https://mealie.sun";
      };

      # syncthing = rec {
      #   enable = true;

      # port = 8013;

      #   dataDir = "/mnt/bigdata/syncthing";

      #   folders = {
      #     "code" = "${dataDir}/Code";
      #     "minecraft" = "${dataDir}/Minecraft";
      #     "music" = "${dataDir}/Music";
      #     "games" = "${dataDir}/Games";
      #     "seedvault-backup" = "${dataDir}/Backups/Phone";
      #     "firefox-sync" = "${dataDir}/Backups/Librewolf";
      #     "dictionaries" = "${dataDir}/Dictionaries";
      #   };

      #   caddy.url = "http://syncthing.sun";
      #   openFirewall = true;
      # };
      #
      restic = {
        server = {
          enable = true;

          port = 8014;

          dataDir = "/mnt/bigdata/restic";
          passwordFile = "/secrets/restic/passwordFile";

          caddy.url = "https://restic.sun";
        };

        client.enable = true;
      };

      radarr = {
        enable = true;

        port = 8015;

        caddy.url = "https://radarr.sun";
      };

      sonarr = {
        enable = true;

        port = 8016;

        caddy.url = "https://sonarr.sun";
      };

      prowlarr = {
        enable = true;

        port = 8017;

        caddy.url = "https://prowlarr.sun";
      };

      bazarr = {
        enable = true;

        port = 8018;

        caddy.url = "https://bazarr.sun";
      };

      lidarr = {
        enable = true;

        port = 8019;

        caddy.url = "https://lidarr.sun";
      };

      recyclarr = {
        enable = true;

        radarr.keyPath = "/secrets/radarr/api-key";
        sonarr.keyPath = "/secrets/sonarr/api-key";
      };

      qbittorrent = {
        enable = true;

        webUIPort = 8020;

        saveDir = "/mnt/bigdata/media/download";

        caddy.url = "https://qbittorrent.sun";
      };

      soulseek = {
        enable = true;

        webUIPort = 8021;

        address = "192.168.15.1";

        downloadDir = "/mnt/bigdata/media/download/slskd";
        sharedDirs = ["/mnt/bigdata/media/music" "/mnt/bigdata/media/classics"];

        environmentFile = "/secrets/slskd/environmentFile";

        caddy.url = "https://soulseek.sun";
      };

      immich = {
        enable = true;

        port = 8022;

        mediaDir = "/mnt/bigdata/immich/upload";

        caddy.url = "http://immich.sun";
      };

      dnsmasq = {
        enable = true;

        openFirewall = true;

        redirects = {
          "mijnmodem.kpn" = "192.168.2.254";

          ".sun" = "192.168.2.119";

          "unifi" = "192.168.2.119";
          "unifi.home" = "192.168.2.119";
        };
      };
    };

    alerts = {
      power.enable = true;
      disk-space.enable = true;
    };

    programs = {
      zsh.enable = true;
      sudo-rs.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
