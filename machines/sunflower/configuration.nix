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

    ./forgejo-runner.nix

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

    "/mnt/bigdata/forgejo" = {
      device = "bigdata/forgejo";
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

  # Configure Cloudflare DNS for Caddy challenges so we don't need to expose any ports.
  services = {
    caddy = {
      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.2.2"];
        hash = "sha256-RLOwzx7+SH9sWVlr+gTOp5VKlS1YhoTXHV4k6r5BJ3U=";
      };

      environmentFile = "/secrets/caddy/environmentFile";

      virtualHosts = {
        "*.sun.guusvanmeerveld.dev" = {
          extraConfig = ''
            tls {
              dns cloudflare {
                zone_token {$CF_ZONE_TOKEN}
                api_token {$CF_API_TOKEN}
              }
            }
          '';
        };
      };
    };

    qbittorrent-nox.address = "192.168.15.1";
    slskd.settings.soulseek.listen_port = 7717;
  };

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

        openFirewall = true;
      };

      jellyfin = {
        enable = true;

        port = 8000;

        caddy.url = "https://jellyfin.sun.guusvanmeerveld.dev";
      };

      jellyseerr = {
        enable = true;

        port = 8001;

        caddy.url = "https://jellyseerr.sun.guusvanmeerveld.dev";
      };

      uptime-kuma = {
        enable = true;

        port = 8002;

        caddy.url = "https://uptime.sun.guusvanmeerveld.dev";
      };

      homeassistant = {
        enable = true;

        port = 8003;

        ntfy.url = "https://ntfy.sun.guusvanmeerveld.dev";

        caddy.url = "https://homeassistant.sun.guusvanmeerveld.dev";
      };

      ntfy = {
        enable = true;

        port = 8004;

        caddy.url = "https://ntfy.sun.guusvanmeerveld.dev";
      };

      miniflux = {
        enable = true;

        port = 8005;

        adminCredentialsFile = "/secrets/miniflux/adminCredentials";

        caddy.url = "https://miniflux.sun.guusvanmeerveld.dev";
      };

      vaultwarden = {
        enable = true;

        port = 8006;

        environmentFile = "/secrets/vaultwarden/environmentFile";

        caddy.url = "https://bitwarden.sun.guusvanmeerveld.dev";
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

        caddy.url = "https://radicale.sun.guusvanmeerveld.dev";
      };

      atuin = {
        enable = true;

        port = 8009;

        caddy.url = "https://atuin.sun.guusvanmeerveld.dev";
      };

      free-epic-games = {
        enable = true;

        port = 8011;

        email = "mail@guusvanmeerveld.dev";

        ntfy.url = "http://0.0.0.0:${toString config.custom.services.ntfy.port}";

        caddy.url = "https://free-epic-games.sun.guusvanmeerveld.dev";
      };

      twitch-miner = {
        enable = true;
        username = "guusvanmeerveld";

        ntfy.url = "http://localhost:${toString config.custom.services.ntfy.port}";
      };

      mealie = {
        enable = true;

        port = 8012;

        caddy.url = "https://mealie.sun.guusvanmeerveld.dev";
      };

      syncthing = rec {
        enable = true;

        port = 8013;

        dataDir = "/mnt/bigdata/syncthing";

        folders = {
          "code" = "${dataDir}/Code";
          "minecraft" = "${dataDir}/Minecraft";
          "music" = "${dataDir}/Music";
          "games" = "${dataDir}/Games";
          "seedvault-backup" = "${dataDir}/Backups/Phone";
          "firefox-sync" = "${dataDir}/Backups/Librewolf";
          "dictionaries" = "${dataDir}/Dictionaries";
        };

        caddy.url = "https://syncthing.sun.guusvanmeerveld.dev";
        openFirewall = true;
      };

      restic = {
        server = {
          enable = true;

          port = 8014;

          dataDir = "/mnt/bigdata/restic";
          passwordFile = "/secrets/restic/passwordFile";

          caddy.url = "https://restic.sun.guusvanmeerveld.dev";
        };

        client.enable = true;
      };

      radarr = {
        enable = true;

        port = 8015;

        caddy.url = "https://radarr.sun.guusvanmeerveld.dev";
      };

      sonarr = {
        enable = true;

        port = 8016;

        caddy.url = "https://sonarr.sun.guusvanmeerveld.dev";
      };

      prowlarr = {
        enable = true;

        port = 8017;

        caddy.url = "https://prowlarr.sun.guusvanmeerveld.dev";
      };

      bazarr = {
        enable = true;

        port = 8018;

        caddy.url = "https://bazarr.sun.guusvanmeerveld.dev";
      };

      lidarr = {
        enable = true;

        port = 8019;

        caddy.url = "https://lidarr.sun.guusvanmeerveld.dev";
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

        caddy.url = "https://qbittorrent.sun.guusvanmeerveld.dev";
      };

      soulseek = {
        enable = true;

        webUIPort = 8021;

        address = "192.168.15.1";

        downloadDir = "/mnt/bigdata/media/download/slskd";
        sharedDirs = ["/mnt/bigdata/media/music" "/mnt/bigdata/media/classics"];

        environmentFile = "/secrets/slskd/environmentFile";

        caddy.url = "https://soulseek.sun.guusvanmeerveld.dev";
      };

      immich = {
        enable = true;

        port = 8022;

        mediaDir = "/mnt/bigdata/immich/upload";

        caddy.url = "https://immich.sun.guusvanmeerveld.dev";
      };

      rustdesk = {
        enable = true;
      };

      forgejo = {
        enable = true;

        largeStorageDir = "/mnt/bigdata/forgejo";

        port = 8023;

        caddy.url = "https://forgejo.sun.guusvanmeerveld.dev";
      };

      grafana = {
        enable = true;

        port = 8024;

        caddy.url = "https://grafana.sun.guusvanmeerveld.dev";
      };

      glance = {
        enable = true;

        port = 8025;

        caddy.url = "https://glance.sun.guusvanmeerveld.dev";
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
