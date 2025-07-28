# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./minecraft.nix
  ];

  boot.tmp.useTmpfs = true;

  zramSwap.enable = true;

  networking.hostName = "crocus";

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

        ipFilter = {
          enable = true;

          vHosts = ["http://syncthing.crocus" "http://adguard.crocus"];
        };
      };

      syncthing = {
        enable = true;

        caddy.url = "http://syncthing.crocus";
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

          "feg" = {
            sendOnly = true;
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

        caddy.url = "http://adguard.crocus";
      };

      motd = {
        enable = true;
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
