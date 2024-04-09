{...}: {
  imports = [
    ./wm
    ./applications
    ./video
    ./sound.nix
    ./networking.nix
    ./nixos.nix
    ./user.nix
    ./locale.nix
  ];
}
