{ config, pkgs, ... }:

{
  imports = [
    ./gtk.nix
    ./programs/zsh.nix
    ./programs/graphical/librewolf.nix
    ./programs/graphical/vscode.nix
    ./programs/services/syncthing.nix
    ./programs/cli/neovim.nix
  ];

  home.file = {
    ".background-image".source = ../wallpaper.jpg;
  };

  programs.home-manager.enable = true;

  home.username = "guus";
  home.homeDirectory = "/home/guus/";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.
  
}