{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bottom
    htop
    # home-manager
    vim
  ];
}