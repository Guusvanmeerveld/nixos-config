{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bottom
    htop
    vim
    unzip
    zip
    doggo
    jq
  ];
}
