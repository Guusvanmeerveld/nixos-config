# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    ../../nixos
  ];

  networking.hostName = "iso";

  environment.systemPackages = with pkgs; [nixos-install-tools];

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };
    };

    services.openssh.enable = true;

    programs = {
      zsh.enable = true;
    };
  };
}
