{ config, pkgs, ... }:

{
  programs.librewolf = {
    enable = true;

    # extensions = with nur-no-packages.repos.firefox-addons; [
    #   bitwarden
    # ];
  };
}
