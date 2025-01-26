# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;

  # zramSwap.enable = true;

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
      ];
    };

    virtualisation.docker = {
      enable = true;

      caddy = {
        enable = true;

        openFirewall = true;

        caddyFile = pkgs.writeText "Caddyfile" ''
          {
            admin off
          }

          mc.guusvanmeerveld.dev {
            reverse_proxy vanilla-server:8123
          }
        '';
      };

      watchtower = {
        enable = true;
        schedule = "0 0 5 * * 1";
      };

      syncthing.enable = true;
    };

    services = {
      minecraft = {
        openFirewall = true;
        openGeyserFirewall = true;
        openVoiceChatFirewall = true;
      };

      openssh.enable = true;
      fail2ban.enable = true;

      motd = {
        enable = true;

        settings = {
          docker = {
            "/watchtower" = "Watchtower";
            "/syncthing" = "Syncthing";
            "/caddy" = "Caddy";
          };
        };
      };
    };

    networking.wireguard = {
      openFirewall = true;
      kernelModules.enable = true;
    };

    programs.zsh.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
