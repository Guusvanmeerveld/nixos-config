{inputs, ...}: {
  imports = [
    ../../nixos
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  system.stateVersion = "24.11";

  # Configure home-manager
  # home-manager = {
  #   config = ./guus/home.nix;
  #   backupFileExtension = "hm-bak";
  #   useGlobalPkgs = true;
  # };

  nixpkgs = {
    overlays = [
      inputs.nix-on-droid.overlays.default
    ];
  };
}
