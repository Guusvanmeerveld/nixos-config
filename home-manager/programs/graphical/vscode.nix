{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    userSettings = {
      "editor.formatOnSave" = true;
      "explorer.confirmDelete" = false;
      "git.confirmSync" = false;
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.colorTheme" = "One Dark Pro Darker";
      "explorer.confirmDragAndDrop" = false;
      "window.zoomLevel" = 1;
      "git.autofetch" = true;
    };

    extensions = with pkgs.vscode-extensions; [
      redhat.java
      scalameta.metals
      pkief.material-icon-theme
      zhuangtongfa.material-theme
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      esbenp.prettier-vscode
      # ms-vscode.atom-keybindings
    ];
  };

  home.packages = with pkgs; [
    nixpkgs-fmt
  ];
}
