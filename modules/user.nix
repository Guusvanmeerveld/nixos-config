{ config, pkgs, ... }:

{
  users.users.guus = {
    isNormalUser = true;
    description = "Guus van Meerveld";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}