# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    ../../nixos/modules

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./shares.nix
  ];

  hardware.enableAllFirmware = true;

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
    user = {
      name = "guus";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLV/ItIM3IxBsxMAKGtrVZwXJfECWh7VGOOKraLYYjP guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoS//iuxi4c4g3ukBsfCVckaoPNKi0O/Dechd0fX1zx guus@laptop"
      ];
    };

    applications = {
      services = {
        docker = {
          enable = true;

          watchtower.enable = true;
          uptime-kuma.enable = true;

          syncthing = {
            enable = true;
            openFirewall = true;
          };

          gitea = {
            enable = true;

            dataDir = "/mnt/share/apps/gitea";
          };

          ntfy = {
            enable = true;

            baseUrl = "https://ntfy.guusvanmeerveld.dev";
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

              http://syncthing.tlp {
                ${blockExternalVisitors}

                reverse_proxy syncthing:8384
              }

              http://uptime.tlp {
                ${blockExternalVisitors}

                reverse_proxy uptime-kuma:3001
              }
            '';
          };
        };

        openssh.enable = true;
        fail2ban.enable = true;
      };

      shell.zsh.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
