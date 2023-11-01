{ config, pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./locale.nix
    ./networking.nix
    ./user.nix
  ];
}