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
  ];

  boot = {
    tmp.cleanOnBoot = true;

    loader = {
      systemd-boot.enable = true;
      timeout = 0;
    };

    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD"; # Or "i965" if using older driver
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Same here

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      # OpenCL support for intel CPUs before 12th gen
      # see: https://github.com/NixOS/nixpkgs/issues/356535
      intel-compute-runtime-legacy1
      vpl-gpu-rt # QSV
      intel-ocl
    ];
  };

  environment.systemPackages = with pkgs; [intel-gpu-tools];

  networking.hostName = "tulip";
  systemd.network.enable = true;

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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGCSWOsW2EIJUmDtoF1hB+e48fotP/5nvsKC89tiJa6 guus@framework-13"
      ];
    };

    hardware = {
      power.thermald.enable = true;
    };

    certificates.enable = true;

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
              credentialsFile = "/secrets/samba/client/media";

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

        ca = {
          enable = true;

          cert = "${../../nixos/certificates/tulip.crt}";
          key = "/secrets/caddy/ca/root.key";
        };

        openFirewall = true;
      };

      immich = {
        enable = true;

        mediaDir = "/mnt/share/apps/immich/upload";

        caddy.url = "http://immich.tlp";
      };

      jellyfin = {
        enable = true;

        caddy.url = "http://jellyfin.tlp";
      };

      jellyseerr = {
        enable = true;

        caddy.url = "https://jellyseerr.tlp";
      };

      uptime-kuma = {
        enable = true;

        caddy.url = "https://uptime.tlp";
      };

      homeassistant = {
        enable = true;

        caddy.url = "https://homeassistant.tlp";
      };

      ntfy = {
        enable = true;

        caddy.url = "https://ntfy.tlp";
      };

      miniflux = {
        enable = true;

        adminCredentialsFile = "/secrets/miniflux/adminCredentials";

        caddy.url = "https://miniflux.tlp";
      };

      vaultwarden = {
        enable = true;

        environmentFile = "/secrets/vaultwarden/environmentFile";

        caddy.url = "https://bitwarden.tlp";
      };

      traccar = {
        enable = true;

        caddy.url = "https://traccar.tlp";
      };

      radicale = {
        enable = true;

        htpasswdFile = "/secrets/radicale/htpasswdFile";

        caddy.url = "https://radicale.tlp";
      };

      atuin = {
        enable = true;

        caddy.url = "https://atuin.tlp";
      };

      unifi = {
        enable = true;

        openFirewall = true;

        caddy.url = "https://unifi";
      };

      dnsmasq = {
        enable = true;

        openFirewall = true;

        redirects = {
          "mijnmodem.kpn" = "192.168.2.254";

          ".tlp" = "192.168.2.35";

          "unifi" = "192.168.2.35";
          "unifi.home" = "192.168.2.35";
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
