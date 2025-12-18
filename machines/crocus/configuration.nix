# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./minecraft
  ];

  boot.tmp.useTmpfs = true;

  zramSwap.enable = true;

  networking = {
    hostName = "crocus";

    # We use systemd-networkd for configuring default interface
    useDHCP = false;

    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      # Ipv6 is not configured on Oracle cloud free tier
      # "2620:fe::fe"
      # "2620:fe::9"
    ];
  };

  systemd.network = {
    enable = true;

    networks."10-wan" = {
      matchConfig.Name = "enp0s3";

      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;

        DNSOverTLS = true;
        DNSSEC = true;
      };

      dns = config.networking.nameservers;

      linkConfig.RequiredForOnline = "routable";
    };
  };

  services = {
    # Use SystemD's builtin DNS resolver
    resolved = {
      enable = true;

      dnsovertls = "true";
      dnssec = "true";

      extraConfig = ''
        Cache=yes
      '';
    };

    adguardhome.settings.dns = {
      # Bind only to Wireguard garden interface, since we want systemd-resolved to still run on 0.0.0.0:53
      bind_hosts = ["10.10.10.1"];

      # Use same upstream DNS servers as system
      upstream_dns = config.networking.nameservers;
      enable_dnssec = true;
    };

    caddy = {
      package = pkgs.custom.caddy-with-plugins;

      environmentFile = "/secrets/caddy/environmentFile";

      virtualHosts = {
        "*.crocus.guusvanmeerveld.dev" = {
          extraConfig = ''
            @external not remote_ip 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8 127.0.0.1/8

            handle @external {
              respond "Not found" 404
            }

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
  };

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };

      ssh.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBe0+LH36GZnNZESUxkhLKSQ0BucJbPL4UARfTwwczSq guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtf3QLEGFwNipavG1GIuX122Wy0zhh6kl0yEOGp8UTW guus@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB07nFBwusgZ/teTPodEkQkwo9A3cHGN+D9TuJ6SC/HF guus@thuisthuis"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN/xxHZBPK+bPbQRiEEGmufiEpLm2AqLTPVKs+3x7qJB guus@phone"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILeMun+e0fe1B+YeSsGb8lxyDDQfhGmnlTOcKncuVoOL guus@framework-13"
      ];
    };

    certificates.enable = true;

    networking.wireguard = {
      enable = true;
      openFirewall = true;

      networks = {
        "garden" = {
          enable = true;
        };
      };
    };

    services = {
      caddy = {
        enable = true;
        openFirewall = true;
      };

      openssh.enable = true;
      fail2ban.enable = true;
      autoUpgrade.enable = true;

      # Enable restic backups of all services that support it.
      restic.client.enable = true;

      mail-server = {
        enable = true;
        openFirewall = true;

        mailDomain = "guusvanmeerveld.dev";

        users = {
          "guus" = {
            catchAll = true;

            sieve = {
              collect = {
                "Web.Github" = ["github.com"];
                "Web.Let's Encrypt" = ["letsencrypt.org"];
                "Games" = ["epicgames.com"];
              };
            };
          };

          "bitwarden" = {
            sendOnly = true;
          };
        };

        smtpRelay = {
          enable = true;

          domain = "smtp.email.eu-amsterdam-1.oci.oraclecloud.com";

          secretsFile = "/secrets/mail-server/relay";
        };
      };

      adguard = {
        enable = true;

        openFirewall = true;

        caddy.url = "https://adguard.crocus.guusvanmeerveld.dev";
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
