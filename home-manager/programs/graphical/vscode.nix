{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    userSettings = {
      "explorer.confirmDelete" = false;
      "workbench.iconTheme" = "material-icon-theme";
      "explorer.confirmDragAndDrop" = false;
      "window.zoomLevel" = 1;
      "workbench.colorTheme" = "One Dark Pro";
      "security.workspace.trust.banner" = "never";
      "telemetry.telemetryLevel" = "off";
      "extensions.autoUpdate" = false;
      "security.workspace.trust.enabled" = false;
      "update.mode" = "manual";

      "nixEnvSelector.suggestion" = false;

      "git.confirmSync" = false;
      "git.autofetch" = true;
      "git.enableSmartCommit" = true;
      "git.openRepositoryInParentFolders" = "always";
      "git.autoStash" = true;

      "editor.formatOnSave" = true;
      "editor.fontFamily" = "'Fira Code', 'Meslo', 'Droid Sans Mono', 'monospace', monospace";
      "editor.fontLigatures" = true;
      "editor.minimap.showSlider" = "always";

      "spellright.notificationClass" = "warning";
      "spellright.configurationScope" = "user";
      "spellright.suggestionsInHints" = false;
      "spellright.language" = [ "en_US" "nl_NL" ];
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
      ban.spellright
      # ms-vscode.atom-keybindings
    ];
  };

  home.packages = with pkgs; [
    nixpkgs-fmt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.nl_nl
  ];
}
