{ pkgs, ... }: {
  home.packages = with pkgs; [
    python3Full
    python3Full.pkgs.pip
  ];
}
