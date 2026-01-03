# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{config, ...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.tmp.useTmpfs = true;

  networking = {
    hostName = "daisy";

    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      # Ipv6 is not configured on Oracle cloud free tier
      # "2620:fe::fe"
      # "2620:fe::9"
    ];

    useDHCP = false;
  };

  systemd.network = {
    enable = true;

    networks."10-wan" = {
      matchConfig.Name = "ens3";

      networkConfig = {
        DHCP = "yes";

        DNSOverTLS = true;
        DNSSEC = true;
      };

      dns = config.networking.nameservers;

      linkConfig.RequiredForOnline = "routable";
    };
  };

  services = {
    logind.settings.Login = {
      RuntimeDirectorySize = "2G";
    };

    # Use SystemD's builtin DNS resolver
    resolved = {
      enable = true;

      dnsovertls = "true";
      dnssec = "true";

      extraConfig = ''
        Cache=yes
      '';
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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpr5+qSs4FRs0CRu2GX8lD/uETy4DgbVvYbukjerUvA61chVxkk3esm6KnWP4U9g0fM2UuU2RCcUFt4xPBJDmg4DzEBZrIcwthg3/LgGbTyxLsSvhLE7TIrZ59R8KL1ppD1d5c/2hoImXNccXFHW4TJ08ziSKS6h8GEpN8YOe6lLbTMaEDkMRm3bu2Z3NRDkyjHvjQ+rk76cv4IUgWnDVOnw1owzOd2uIjJRc+gmGXFaO77l2pqib9NAUKERNq/K0Q0zXTeKNf/zBpsE2/GTxa3zZN2Iylqac/1ZVE6B+U8RhFOulK95vPiJZyXsMpbiVsIbhTXcx3xqPnQD5gH6N8AvkiMV6nRlUAWvNI4Pflm0GMKLMq3CSKJjCFDDoc0ZYYw2aIBzH2dU1lZ/NO4S6pN7sEQWwFtWeuY2trIgYl75lAXwds9aKKtNC2/6C24qr6S8PCba7EkCLZxgWyuADvuIe/lAWFLrUUC9qkG/bcbhxcCMa6DjzPLa1H6+fBJ20= guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIo/BdLnkczmsSoGruK/5ITnOnUqZbJbwsG8B8sefwpc guus@phone"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGaKXB270OnVQQd1Vtj39vIblkCf5/d3iYDul3m4z8Az guus@framework-13"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEdUGhKB39lTbRRw+6YomIDg6rK6dlrLYRJYkcIHz/+ guus@thuisthuis"
      ];
    };

    programs = {
      zsh.enable = true;
      sudo-rs.enable = true;
    };

    networking.wireguard = {
      enable = true;
      openFirewall = true;

      networks = {
        "shared-backups" = {
          enable = true;
        };
      };
    };

    services = {
      openssh.enable = true;
      fail2ban.enable = true;
      autoUpgrade.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
