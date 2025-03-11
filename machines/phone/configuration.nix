{
  pkgs,
  inputs,
  outputs,
  shared,
  lib,
  ...
}: {
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment = {
    etcBackupExtension = ".bak";

    packages = with pkgs; [vim git zsh openssh unzip zip htop speedtest-cli inetutils doggo perl procps killall diffutils findutils utillinux tzdata hostname man gnugrep gnupg gnused gnutar gawk bzip2 gzip xz];
  };

  time.timeZone = "Europe/Amsterdam";

  user = {
    shell = "${pkgs.zsh}/bin/zsh";
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  terminal.font = "${pkgs.fira-code-nerdfont}/share/fonts/truetype/NerdFonts/FiraCodeNerdFontMono-Regular.ttf";

  # Configure home-manager
  home-manager = {
    config = ./guus/home.nix;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {inherit inputs outputs shared;};
    useGlobalPkgs = true;
  };

  system.stateVersion = "24.05";
}
