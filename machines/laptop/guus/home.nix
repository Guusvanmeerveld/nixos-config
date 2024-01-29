{ config, pkgs, ... }:

{
  imports = [
    ../../../home-manager/gtk.nix
    ../../../home-manager/i3.nix
    ../../../home-manager/programs/zsh.nix
    ../../../home-manager/programs/cli
    ../../../home-manager/programs/graphical
    ../../../home-manager/programs/services/syncthing.nix
  ];

  home.file = {
    ".background-image".source = ../../../wallpaper-normal.jpg;
  };

  programs.home-manager.enable = true;

  home.username = "guus";
  home.homeDirectory = "/home/guus";

  nixpkgs = {
    # Configure your nixpkgs instance
    # config = {
    #   # Disable if you don't want unfree packages
    #   allowUnfree = true;
    #   # Workaround for https://github.com/nix-community/home-manager/issues/2942
    #   allowUnfreePredicate = _: true;
    # };
  };

  home.packages = with pkgs; [
    rpi-imager
  ];


  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

}
