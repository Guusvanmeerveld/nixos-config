{
  pkgs,
  inputs,
  outputs,
  shared,
  ...
}: {
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment = {
    etcBackupExtension = ".bak";

    packages = with pkgs; [vim git zsh openssh btop unzip zip];
  };

  time.timeZone = "Europe/Amsterdam";

  user = {
    shell = "${pkgs.zsh}/bin/zsh";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    warn-dirty = false
  '';

  # Configure home-manager
  home-manager = {
    config = ./guus/home.nix;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {inherit inputs outputs shared;};
    useGlobalPkgs = true;
  };

  system.stateVersion = "24.05";
}
