{...}: {
  imports = [
    ./wm
    ./dm
    ./hardware
    ./applications
    ./networking.nix
    ./nixos.nix
    ./user.nix
    ./locale.nix
    ./journald.nix
    ./security.nix
    ./nixpkgs-issue-55674.nix
    ./builders.nix
  ];
}
