{ config, pkgs, ... }:

{
  networking.firewall.enable = true;

  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;
}