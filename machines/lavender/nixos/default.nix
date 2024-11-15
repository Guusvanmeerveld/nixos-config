# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../../nixos/modules

    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    # Module that allows the tv remote to control kodi
    ./cec.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  boot.kernelParams = ["snd_bcm2835.enable_hdmi=1"];

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  hardware = {
    opengl.enable = true;

    raspberry-pi."4" = {
      fkms-3d.enable = true;
      i2c1.enable = true;
    };
  };

  networking.hostName = "lavender";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall = {
    allowedTCPPorts = [1234];
    allowedUDPPorts = [5353];
  };

  custom = {
    user = {
      name = "guus";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbtyJ9N/jgR9L04Y09PAlHPR6n2PwdBF3WAn9tUd+fn guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGu7eHkmd1YUi3sjbYG299Gvwlq2fpy2AIlLTXgUR49j guus@laptop"
      ];
    };

    hardware = {
      pipewire.enable = true;
      argon40.enable = true;
    };

    applications = {
      graphical.kodi.enable = true;

      services = {
        openssh.enable = true;
        fail2ban.enable = true;
      };

      shell.zsh.enable = true;
    };

    builders = {
      enable = true;

      machines = [
        {
          hostName = "crocus";
          system = "aarch64-linux";
        }
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
