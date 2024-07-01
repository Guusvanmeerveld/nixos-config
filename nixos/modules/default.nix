{...}: {
  imports = [
    ./wm
    ./dm
    ./applications
    ./video
    ./pipewire.nix
    ./networking.nix
    ./nixos.nix
    ./user.nix
    ./locale.nix
    ./journald.nix
  ];
}
