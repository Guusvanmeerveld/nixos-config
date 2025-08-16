# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    ../../nixos

    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    inputs.vpn-confinement.nixosModules.default
  ];

  boot.blacklistedKernelModules = ["onboard_usb_hub"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };

    "/mnt/data" = {
      device = "zpool/data";
      fsType = "zfs";
    };

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

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  hardware = {
    raspberry-pi."4" = {
      i2c1.enable = true;
    };

    enableRedistributableFirmware = true;
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;

    hostName = "orchid";

    # Required for ZFS
    hostId = "04ae0999";
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
      }) ["radarr" "sonarr" "bazarr" "qbittorrent" "lidarr" "slskd"]));
  };

  services.qbittorrent-nox.address = "192.168.15.1";

  systemd.services = {
    qbittorrent-nox.vpnConfinement = {
      enable = true;
      vpnNamespace = "mullvad";
    };

    slskd.vpnConfinement = {
      enable = true;
      vpnNamespace = "mullvad";
    };
  };

  vpnNamespaces.mullvad = {
    # The name is limited to 7 characters

    enable = true;
    wireguardConfigFile = "/secrets/mullvad/wgFile";

    accessibleFrom = [
      "127.0.0.0/24"
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

  services.soularr.lidarr.apiKey = "e0d013be2a0c4c1bbba82a33028fec4a"; # pragma: allowlist secret`

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };

      ssh.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPveisofM9+vfj896DbwpKZJETzE3pqNA86y3Wdcdbt1 guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGu7eHkmd1YUi3sjbYG299Gvwlq2fpy2AIlLTXgUR49j guus@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKw8JJfcBC8cITSr9UWo6rG9pBL3U5oZlokBF/BoyCYN guus@thuisthuis"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwRnPjxU2v2+AgKtnkZoMG7tOnuo+X2aqm+GV0KxeyT guus@phone"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJF3peesjDreX3V3jx3rAdY1sWd1LreNPhn1Lbzhyiu guus@framework-13"
      ];
    };

    fs.zfs.enable = true;

    hardware = {
      argon40 = {
        enable = true;
        eon.enable = true;
      };
    };

    certificates.enable = true;

    networking = {
      wireguard = {
        enable = true;

        networks = {
          "garden" = {
            enable = true;
            keepAlive = true;
          };
        };
      };
    };

    services = {
      openssh.enable = true;
      # fail2ban.enable = true;
      autoUpgrade.enable = true;

      caddy = {
        enable = true;

        ca = {
          enable = true;

          cert = "${../../nixos/certificates/orchid.crt}";
          key = "/secrets/caddy/ca/root.key";
        };

        ipFilter = {
          enable = true;

          whitelist = ["10.10.10.0/24" "192.168.2.0/24"];

          vHosts = [
            "http://syncthing.chd"
            "https://qbittorrent.chd"
            "https://restic.chd"
            "https://radarr.chd"
            "https://sonarr.chd"
            "https://prowlarr.chd"
          ];
        };

        openFirewall = true;
      };

      syncthing = rec {
        enable = true;

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

        caddy.url = "http://syncthing.chd";
        openFirewall = true;
      };

      restic = {
        server = {
          enable = true;

          dataDir = "/mnt/bigdata/restic";
          passwordFile = "/secrets/restic/passwordFile";

          caddy.url = "https://restic.chd";
        };

        client.enable = true;
      };

      qbittorrent = {
        enable = true;

        saveDir = "/mnt/bigdata/media/download";

        caddy.url = "https://qbittorrent.chd";
      };

      radarr = {
        enable = true;

        caddy.url = "https://radarr.chd";
      };

      sonarr = {
        enable = true;

        caddy.url = "https://sonarr.chd";
      };

      prowlarr = {
        enable = true;

        caddy.url = "https://prowlarr.chd";
      };

      bazarr = {
        enable = true;

        caddy.url = "https://bazarr.chd";
      };

      lidarr = {
        enable = true;

        caddy.url = "https://lidarr.chd";
      };

      samba.server = {
        enable = true;

        shares = {
          iso = "/mnt/data/iso";
          games = "/mnt/data/games";
          media = "/mnt/bigdata/media";
          immich = "/mnt/bigdata/immich";
        };
      };

      soulseek = {
        enable = true;

        address = "192.168.15.1";

        downloadDir = "/mnt/bigdata/media/download/slskd";
        sharedDirs = ["/mnt/bigdata/media/music"];

        environmentFile = "/secrets/slskd/environmentFile";

        caddy.url = "https://soulseek.chd";
      };

      motd = {
        enable = true;

        settings = {
          fileSystems = {
            "data" = "/mnt/data";
            "media" = "/mnt/bigdata/media";
          };
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

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
