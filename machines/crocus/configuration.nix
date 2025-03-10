# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  shared,
  ...
}: {
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB07nFBwusgZ/teTPodEkQkwo9A3cHGN+D9TuJ6SC/HF guus@thuisthuis"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN/xxHZBPK+bPbQRiEEGmufiEpLm2AqLTPVKs+3x7qJB guus@phone"
      ];
    };

    networking.wireguard = let
      gardenConfig = shared.wireguard.networks.garden;
    in {
      enable = true;
      openFirewall = true;

      interfaces = {
        "garden" = {
          addresses = ["${gardenConfig.server.address}/24"];
          privateKeyFile = "/secrets/wireguard/garden/private";

          peers =
            lib.mapAttrsToList (name: peer: {
              publicKey = peer.publicKey;
              allowedIps = ["${peer.address}/32"];
            })
            gardenConfig.clients;
        };
      };
    };

    virtualisation.docker = {
      enable = true;

      watchtower = {
        enable = true;
        schedule = "0 0 5 * * 1";
      };
    };

    services = {
      minecraft = {
        openFirewall = true;
        openGeyserFirewall = true;
        openVoiceChatFirewall = true;
      };

      caddy = {
        enable = true;
        openFirewall = true;
      };

      syncthing = {
        enable = true;

        caddy.url = "http://syncthing.crocus";
        openFirewall = true;
      };

      openssh.enable = true;
      fail2ban.enable = true;
      autoUpgrade.enable = true;

      dnsmasq = {
        enable = true;

        openFirewall = true;

        redirects = let
          gardenConfig = shared.wireguard.networks.garden;
          machines =
            gardenConfig.clients
            // {
              crocus = gardenConfig.server;
            };
        in
          # Map all wireguard TLD's to their respective addresses.
          with lib;
            mkMerge [
              # Map tlds to machine's addresses
              (mapAttrs' (
                  clientName: {
                    tld,
                    address,
                    ...
                  }:
                    nameValuePair ".${tld}" address
                )
                machines)
              # Map machine hostnames to addresses as well
              (mapAttrs' (clientName: {address, ...}: nameValuePair clientName address) machines)
            ];
      };

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

    programs.zsh.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
