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
    ./security.nix
    ./nixpkgs-issue-55674.nix
    ./bluetooth.nix
  ];
}
