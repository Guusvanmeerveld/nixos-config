# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/essential.nix
      ../../modules/plymouth.nix
      ../../modules/programs/basic.nix
      ../../modules/programs/docker.nix
      ../../modules/programs/git.nix
      ../../modules/programs/shell.nix
      ../../modules/programs/steam.nix
      ../../modules/video/amd.nix
      ../../modules/wm/i3.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "laptop";

  # Enable networking
  networking.networkmanager.enable = true;

  services.logind = {
    lidSwitch = "hibernate";
    # powerKeyLongPress = "reboot";
    # powerKey = "poweroff";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
