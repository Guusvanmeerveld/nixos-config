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

  # Bootloader.
  boot.loader = {
    grub = {
      device = "/dev/vda";
    };
  };

  networking.hostName = "rose";

  # Enable networking
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;

    openFirewall = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  custom = {
    user = "guus";

    applications = {
      shell.zsh.enable = true;

      docker.enable = true;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [80 443];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
