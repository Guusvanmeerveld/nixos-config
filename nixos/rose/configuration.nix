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

    ./modules

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
    user = {
      name = "guus";
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYlOu/F/BdrbrfTV3M1UzKNmnOzMhgjvJpzmtjmqIALoDFLrDl9UJIUdkrbe2Wc/XxSC81+3SBjpHdJmnCEWZXqjPooE6LyLC+wUvTSeVyL/OmdeysjT998TBmI5AmLYxq+7aPIEYvi4ThRL3pYe0pqqpcjVYl2vFtV3Tl4++4M19pBYxfZ5cTu7q0whvQk5JJs3HuLYYqjLhYHzUowsUfqinlbcExY9N0wcUk5XP30fwyyjcB4V7rytqV69jt7sT/Qm1A51U8TTuAlCS+nqzowilstzntdxW17FdBsD8EvWHhQ9jk/sjmLik2axjz4eHCaFJTupOnxX/vwraw81i1KDG9aOTfcBiK8eHElcqUT+kKo5/r6LEmFrwtyIdHvsxL0gOR1sH1Hb1c1VWsuv/7SMRmYeSfyTlGw27vCNOcqCCgGiXsDYmvMI+v/huFjJYHi+KyA8zSeTlPijX/iP4VZOlo2waLuin6u/VdiZqxvoFHMidlQtR1tP5j2E8YbOM= guus@desktop"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgJ+CtiME7co6zBpdQytDUCF3lmM53dSE6meLHg2IJEt8EhX1QT4B0g4ep9fjCwAgmGAFjhUoQBPFwMaybWVeQWaxy8YAi+IexlJcQgPOBCapbtXgESAOuimpSyC9O0SQWULKeK8fuE1IpSBgXJXmhHP9SViu5RJ9YhCI17qvE2wHA9bFJGs+do/pwvjy3QLulVMDfxuft3HKAafEKTIqy1/OKqxeFalVOpZhbEsTx7gmKMfncHhkCTU7eE1s2umet+bD3kOxWwfvJuztxz64roe+NOuDC5m1VaglkHF8a1Ohgj4wS6g0/SC1jQk69P/aVCXGRhvVGCvCTDeUeaPOuc1sDbOXmsA9RlBhkIOUAXx1frdcTNp3rJ1nV0hKC+0QIbyZZhflIgzZGT8Kc9RgseY3XQry/tmW29ax8ZM3/y+BVsW7q7lyLynsnN66j5UgUUOQs+1EwftFjPbq/yUUcXVcFdAOckeOlyxLVeSchJyqCvjEkYvk7HSDDwamHUiE= guus@laptop"
      ];
    };

    applications = {
      shell.zsh.enable = true;

      # docker.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
