{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bottom
    home-manager
  ];
}