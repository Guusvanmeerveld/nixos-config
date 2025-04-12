# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./agenix.nix
  ];

  boot = {
    tmp.cleanOnBoot = true;

    loader = {
      systemd-boot.enable = true;
      timeout = 0;
    };
  };

  networking.hostName = "tulip";

  # Enable networking
  networking.networkmanager.enable = true;

  users = {
    users = {
      "media" = {
        uid = 1700;

        group = "media";
        isSystemUser = true;
      };
    };

    groups = {
      "media" = {
        gid = 1700;
      };
    };
  };

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };

      ssh.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgGEu08LD9FAmK3N6RlMkx2KjEuFhb3wAIQ0RXypdsh guus@thuisthuis"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLV/ItIM3IxBsxMAKGtrVZwXJfECWh7VGOOKraLYYjP guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoS//iuxi4c4g3ukBsfCVckaoPNKi0O/Dechd0fX1zx guus@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzwMdOGHng1x0JIl8mVI66HlzCP/nMN8oGcLUsb9617 guus@phone"
      ];
    };

    hardware = {
      power.thermald.enable = true;
    };

    networking.wireguard = {
      enable = true;

      networks = {
        "garden" = {
          enable = true;
          keepAlive = true;
        };
      };
    };

    virtualisation.docker = {
      enable = true;

      watchtower.enable = true;
      uptime-kuma.enable = true;
      homeassistant.enable = true;

      jellyfin = {
        enable = true;

        mediaDir = "/mnt/share/media";

        user.gid = config.users.groups."media".gid;
      };

      qbittorrent = {
        enable = true;

        # Make qBittorrent part of media group so it has access to media files
        user.gid = config.users.groups."media".gid;

        downloadDir = "/mnt/share/media/download";
      };

      # VPN container
      gluetun = {
        enable = true;

        secretsFile = config.age.secrets.gluetun.path;
      };

      servarr = {
        enable = true;

        downloadDir = "/mnt/share/media/download";
        tvDir = "/mnt/share/media/shows";
        movieDir = "/mnt/share/media/movies";

        user.gid = config.users.groups."media".gid;

        bazarr.enable = true;
        prowlarr.enable = true;
        radarr.enable = true;
        sonarr.enable = true;
      };

      nextcloud = {
        enable = true;

        dataDir = "/mnt/share/apps/nextcloud";

        secretsFile = config.age.secrets.nextcloud.path;
      };

      ntfy = {
        enable = true;

        externalDomain = "https://ntfy.guusvanmeerveld.dev";
      };

      immich = {
        enable = true;

        secretsFile = config.age.secrets.immich.path;

        uploadDir = "/mnt/share/apps/immich/upload";
      };

      unifi = {
        enable = true;

        openFirewall = true;

        secretsFile = config.age.secrets.unifi.path;
      };

      caddy = let
        modemIp = "192.168.2.254";

        blockExternalVisitors = ''
          @blocked remote_ip ${modemIp}
          respond @blocked "Nope" 403
        '';
      in {
        enable = true;
        openFirewall = true;

        caddyFile = pkgs.writeText "Caddyfile" ''
          http://jellyfin.tlp {
            ${blockExternalVisitors}

            reverse_proxy jellyfin:8096
          }



          http://uptime.tlp {
            ${blockExternalVisitors}

            reverse_proxy uptime-kuma:3001
          }

          http://gitea.tlp {
            ${blockExternalVisitors}

            reverse_proxy gitea:3000
          }

          http://nextcloud.tlp {
            ${blockExternalVisitors}

            reverse_proxy nextcloud:80
          }

          http://homeassistant.tlp {
            ${blockExternalVisitors}

            reverse_proxy homeassistant:8123
          }

          http://immich.tlp {
            ${blockExternalVisitors}

            reverse_proxy immich-server:2283
          }

          http://portfolio.tlp {
            ${blockExternalVisitors}

            reverse_proxy portfolio:3000
          }

          http://qbittorrent.tlp {
            ${blockExternalVisitors}

            reverse_proxy gluetun:8080
          }

          http://radarr.tlp {
            ${blockExternalVisitors}

            reverse_proxy radarr:7878
          }

          http://sonarr.tlp {
            ${blockExternalVisitors}

            reverse_proxy sonarr:8989
          }

          http://prowlarr.tlp {
            ${blockExternalVisitors}

            reverse_proxy prowlarr:9696
          }

          http://bazarr.tlp {
            ${blockExternalVisitors}

            reverse_proxy bazarr:6767
          }
        '';
      };
    };

    services = {
      # Mount all the shares that are needed for the docker services
      samba.client = {
        enable = true;

        shares = [
          {
            host = {
              dir = "/mnt/share/media";

              inherit (config.users.users.media) uid;
              inherit (config.users.groups.media) gid;

              dirMode = "0775";
              fileMode = "0664";
            };

            remote = {
              host = "192.168.2.195";
              dir = "media";
            };
          }
          {
            host = {
              dir = "/mnt/share/apps/nextcloud";

              inherit (config.users.users.www-data) uid;
              inherit (config.users.groups.www-data) gid;

              dirMode = "0770";
              fileMode = "0770";
            };

            remote = {
              host = "192.168.2.195";
              dir = "nextcloud";
            };
          }
          {
            host = {
              dir = "/mnt/share/apps/immich";

              inherit (config.users.users.immich) uid;
              inherit (config.users.groups.immich) gid;
            };

            remote = {
              host = "192.168.2.195";
              dir = "immich";
            };
          }
        ];
      };

      openssh.enable = true;
      fail2ban.enable = true;
      autoUpgrade.enable = true;

      dnsmasq = {
        enable = true;

        openFirewall = true;

        redirects = {
          "mijnmodem.kpn" = "192.168.2.254";

          ".sun" = "192.168.2.119";
          ".tlp" = "192.168.2.35";

          "orchid" = "192.168.2.195";
          "tulip" = "192.168.2.35";

          "unifi" = "192.168.2.35";
          "unifi.home" = "192.168.2.35";
        };
      };

      # motd = {
      #   enable = true;

      #   settings = {
      #     docker = {
      #       "/caddy" = "Caddy";
      #       "/watchtower" = "Watchtower";
      #       "/uptime-kuma" = "Uptime Kuma";
      #       "/syncthing" = "Syncthing";
      #     };

      #     fileSystems = {
      #       "media" = "/mnt/share/media";
      #     };
      #   };
      # };
    };

    programs = {
      zsh.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
