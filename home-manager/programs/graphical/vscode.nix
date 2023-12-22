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
      "explorer.confirmDragAndDrop" = false;
      "window.zoomLevel" = 1;
      "git.autofetch" = true;
      "git.enableSmartCommit" = true;
      "editor.fontFamily" = "'Fira Code', 'Meslo', 'Droid Sans Mono', 'monospace', monospace";
      "editor.fontLigatures" = true;
      "workbench.colorTheme" = "One Dark Pro";
      "security.workspace.trust.banner" = "never";
      "telemetry.telemetryLevel" = "off";
      "extensions.autoUpdate" = false;
      "editor.minimap.showSlider" = "always";
      "git.openRepositoryInParentFolders" = "always";
      "update.mode" = "manual";
      "nixEnvSelector.suggestion" = false;
      "security.workspace.trust.enabled" = false;
    };

    extensions = with pkgs.vscode-extensions; [
      zhuangtongfa.material-theme
      jnoortheen.nix-ide
      scalameta.metals
      pkief.material-icon-theme
      rust-lang.rust-analyzer
      arrterian.nix-env-selector
      esbenp.prettier-vscode
      ms-toolsai.jupyter
      ms-python.python
      tamasfe.even-better-toml
      james-yu.latex-workshop
      redhat.java
      vscjava.vscode-maven
      vscjava.vscode-java-debug
      vscjava.vscode-java-dependency
      vadimcn.vscode-lldb
      # ms-vscode.atom-keybindings
    ];
  };

  home.packages = with pkgs; [
    nixpkgs-fmt
  ];
}
