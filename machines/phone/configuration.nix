{
  inputs,
  pkgs,
  ...
}: {
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment = {
    etcBackupExtension = ".bak";

    packages = with pkgs; [vim git zsh openssh btop unzip zip];
  };

  time.timeZone = "Europe/Amsterdam";

  nixpkgs = {
    overlays = [
      inputs.nix-on-droid.overlays.default
    ];
  };

  user = {
    shell = "${pkgs.zsh}/bin/zsh";
    userName = "guus";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Configure home-manager
  # home-manager = {
  #   config = ./guus/home.nix;
  #   backupFileExtension = "hm-bak";
  #   useGlobalPkgs = true;
  # };

  system.stateVersion = "24.11";
}
