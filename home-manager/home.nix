{ config, pkgs, ... }:

{
  imports = [
    ./gtk.nix
    ./i3.nix
    ./programs/zsh.nix
    ./programs/dev/python.nix
    # ./programs/dev/rust.nix
    ./programs/graphical/kitty.nix
    ./programs/graphical/thunar.nix
    ./programs/graphical/evince.nix
    ./programs/graphical/flameshot.nix
    ./programs/graphical/librewolf.nix
    ./programs/graphical/discord.nix
    ./programs/graphical/vscode.nix
    ./programs/graphical/spotify.nix
    ./programs/graphical/libreoffice.nix
    ./programs/graphical/matrix.nix
    ./programs/graphical/games/minecraft.nix
    ./programs/graphical/games/heroic.nix
    ./programs/services/syncthing.nix
    ./programs/cli/git.nix
    ./programs/cli/neovim.nix
  ];

  home.file = {
    ".background-image".source = ../wallpaper.jpg;
  };

  programs.home-manager.enable = true;

  home.username = "guus";
  home.homeDirectory = "/home/guus";

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };


  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

}
