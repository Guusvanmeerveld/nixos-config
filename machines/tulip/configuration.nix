# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{config, ...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
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

    services = {
      # Mount all the shares that are needed for the docker services
      samba.client = {
        enable = true;

        shares = [
          {
            host = {
              dir = "/mnt/share/media";

              inherit (config.users.users.jellyfin) uid;
              inherit (config.users.groups.jellyfin) gid;

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

      caddy = {
        enable = true;

        openFirewall = true;
      };

      immich = {
        enable = true;

        mediaDir = "/mnt/share/apps/immich/upload";
        secretsFile = "/secrets/immich/secrets";

        caddy.url = "http://immich.tlp";
      };

      jellyfin = {
        enable = true;

        caddy.url = "http://jellyfin.tlp";
      };

      uptime-kuma = {
        enable = true;

        caddy.url = "http://uptime.tlp";
      };

      homeassistant = {
        enable = true;

        caddy.url = "http://homeassistant.tlp";
      };

      ntfy = {
        enable = true;

        caddy.url = "http://ntfy.tlp";
      };

      unifi = {
        enable = true;

        caddy.url = "https://unifi";
      };

      dnsmasq = {
        enable = true;

        openFirewall = true;

        redirects = {
          "mijnmodem.kpn" = "192.168.2.254";

          ".tlp" = "192.168.2.35";

          "orchid" = "192.168.2.195";
          "tulip" = "192.168.2.35";

          "unifi" = "192.168.2.35";
          "unifi.home" = "192.168.2.35";
        };
      };
    };

    programs = {
      zsh.enable = true;
      sudo-rs.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
