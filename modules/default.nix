{ config, pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./locale.nix
    ./networking.nix
    ./user.nix
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
  };
}
