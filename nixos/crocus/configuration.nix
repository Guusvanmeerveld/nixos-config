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

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;

  # zramSwap.enable = true;

  networking.hostName = "crocus";

  # Enable networking
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;

    openFirewall = true;

    settings = {
      PasswordAuthentication = false;
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@guusvanmeerveld.dev";

  custom = {
    user = {
      name = "guus";
      authorizedKeys = [
	      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBe0+LH36GZnNZESUxkhLKSQ0BucJbPL4UARfTwwczSq guus@desktop"
      ];
    };

    applications = {
      services = {
        nginx.enable = true;
      };

      shell.zsh.enable = true;
      docker.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
