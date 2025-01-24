{
  imports = [
    ./services
    ./virtualisation
    ./programs
    ./networking
    ./wm
    ./dm
    ./hardware
    ./nixos.nix
    ./user.nix
    ./locale.nix
    ./journald.nix
    ./security.nix
    ./nixpkgs-issue-55674.nix
    ./builders.nix
  ];
}
