{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    extensions = with pkgs.vscode-extensions; [
      redhat.java
      scalameta.metals
      pkief.material-icon-theme
      zhuangtongfa.material-theme
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      # ms-vscode.atom-keybindings
    ];
  };

  home.packages = with pkgs; [
    nixpkgs-fmt
  ];
}