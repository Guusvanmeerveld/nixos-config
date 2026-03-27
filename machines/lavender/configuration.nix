# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../nixos

    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    # Module that allows the tv remote to control kodi
    # ./cec.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  boot.kernelParams = [
    "snd_bcm2835.enable_hdmi=1"
    "zswap.enabled=1" # enables zswap
    "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  hardware = {
    graphics = {
      enable = true;
    };

    raspberry-pi."4" = {
      fkms-3d.enable = true;
      i2c1.enable = true;
    };
  };

  networking = {
    hostName = "lavender";

    # We use systemd-networkd for configuring default interface
    useDHCP = false;
  };

  # Enable networking
  systemd.network = {
    enable = true;

    networks."10-wan" = {
      matchConfig.Name = "end0";

      networkConfig = {
        DHCP = "ipv4";

        DNSOverTLS = false;
        DNSSEC = false;
      };

      linkConfig.RequiredForOnline = "routable";
    };
  };

  services = {
    caddy.virtualHosts = {
      "*.lav.guusvanmeerveld.dev" = {
        extraConfig = ''
          tls {
            dns cloudflare {$CF_API_TOKEN}
          }
        '';
      };
    };

    # Use SystemD's builtin DNS resolver
    resolved = {
      enable = true;

      settings.Resolve = {
        DNSOverTLS = true;
        DNSSEC = true;
        Cache = "yes";
      };
    };

    adguardhome.settings.dns = {
      bind_hosts = ["192.168.0.229"];
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbtyJ9N/jgR9L04Y09PAlHPR6n2PwdBF3WAn9tUd+fn guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGu7eHkmd1YUi3sjbYG299Gvwlq2fpy2AIlLTXgUR49j guus@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJPCjORqUI36CLKFecdYTWMznUqaNsVMQlYL7Kb9fxO guus@framework-13"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFBdRpLl59bKoPAqCvryYJbPBKKci5zDBPgDnohxS8YT guus@thuisthuis"
      ];
    };

    hardware = {
      sound.pipewire.enable = true;
      argon40.enable = true;
    };

    certificates.enable = true;

    services = {
      openssh.enable = true;
      fail2ban.enable = true;

      adguard = {
        enable = true;
        openFirewall = true;

        caddy.url = "https://adguard.lav.guusvanmeerveld.dev";
      };

      homeassistant = {
        enable = true;

        caddy.url = "https://homeassistant.lav.guusvanmeerveld.dev";
      };

      caddy = {
        enable = true;
        openFirewall = true;
      };
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

    alerts = {
      power.enable = true;
      disk-space.enable = true;
    };

    programs = {
      zsh.enable = true;
      sudo-rs.enable = true;
    };

    builders = {
      enable = true;

      machines = [
        {
          hostName = "crocus";
          system = "aarch64-linux";
        }
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
