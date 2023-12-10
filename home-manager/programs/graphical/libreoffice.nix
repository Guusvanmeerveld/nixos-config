{ pkgs, ... }: {
  home.packages = with pkgs; [
    libreoffice
    hunspellDicts.nl_nl
    hunspellDicts.en-us
  ];
}
