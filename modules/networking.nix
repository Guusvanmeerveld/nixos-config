{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22000 ];
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
