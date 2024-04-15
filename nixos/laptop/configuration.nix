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
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "laptop";

  # Enable networking
  networking.networkmanager.enable = true;

  services.xserver.libinput = {
    touchpad = {
      naturalScrolling = false;
      accelProfile = "flat";
    };
  };

  services.logind = {
    lidSwitch = "hibernate";
    # powerKeyLongPress = "reboot";
    # powerKey = "poweroff";
  };

  custom = {
    user.name = "guus";

    applications = {
      shell.zsh.enable = true;

      docker.enable = true;
    };

    video.amd = {
      enable = true;
      vrr.enable = true;
    };

    wm.i3.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
