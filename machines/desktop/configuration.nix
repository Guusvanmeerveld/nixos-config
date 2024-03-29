# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan. 
      ./hardware-configuration.nix
      ./autorandr.nix
      ../../modules
      ../../modules/sshd.nix
      ../../modules/qemu.nix
      ../../modules/kdeconnect.nix
      ../../modules/programs/basic.nix
      ../../modules/programs/git.nix
      ../../modules/programs/shell.nix
      ../../modules/programs/docker.nix
      ../../modules/programs/steam.nix
      ../../modules/plymouth.nix
      ../../modules/input-devices.nix
      ../../modules/video/amd.nix
      ../../modules/wm/i3.nix
    ];

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    grub = {
      enable = true;

      efiSupport = true;
      useOSProber = true;
      device = "nodev";
    };

    grub2-theme = {
      enable = true;
      theme = "stylish";
      footer = true;
    };
  };

  hardware.ckb-next.enable = true;

  networking.networkmanager.enable = true;

  # DNS
  # networking.networkmanager.insertNameservers = [ "192.168.2.119" ];

  networking.hostName = "desktop"; # Define your hostname.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
