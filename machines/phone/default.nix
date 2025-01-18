{...}: {
  # imports = [
  #   ../../nixos
  # ];

  home-manager.config = ./home.nix;

  system.stateVersion = "24.05";
}
