# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../modules

    ./secrets.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;

  # zramSwap.enable = true;

  networking.hostName = "daisy";

  # Enable networking
  networking.networkmanager.enable = true;

  services.logind.extraConfig = ''
    RuntimeDirectorySize=2G
  '';

  services.openssh = {
    enable = true;

    openFirewall = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@guusvanmeerveld.dev";

  services.nginx = {
    virtualHosts = {
      "epicgames.guusvanmeerveld.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8800/";
          recommendedProxySettings = true;
        };
      };
    };
  };

  custom = {
    user = {
      name = "guus";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsTe0VL1j/6gHUUEM+ZBlsFKUZ9X7w/986R64hxcSrD guus@laptop"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpr5+qSs4FRs0CRu2GX8lD/uETy4DgbVvYbukjerUvA61chVxkk3esm6KnWP4U9g0fM2UuU2RCcUFt4xPBJDmg4DzEBZrIcwthg3/LgGbTyxLsSvhLE7TIrZ59R8KL1ppD1d5c/2hoImXNccXFHW4TJ08ziSKS6h8GEpN8YOe6lLbTMaEDkMRm3bu2Z3NRDkyjHvjQ+rk76cv4IUgWnDVOnw1owzOd2uIjJRc+gmGXFaO77l2pqib9NAUKERNq/K0Q0zXTeKNf/zBpsE2/GTxa3zZN2Iylqac/1ZVE6B+U8RhFOulK95vPiJZyXsMpbiVsIbhTXcx3xqPnQD5gH6N8AvkiMV6nRlUAWvNI4Pflm0GMKLMq3CSKJjCFDDoc0ZYYw2aIBzH2dU1lZ/NO4S6pN7sEQWwFtWeuY2trIgYl75lAXwds9aKKtNC2/6C24qr6S8PCba7EkCLZxgWyuADvuIe/lAWFLrUUC9qkG/bcbhxcCMa6DjzPLa1H6+fBJ20= guus@desktop"
      ];
    };

    applications = {
      shell.zsh.enable = true;
      docker.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
