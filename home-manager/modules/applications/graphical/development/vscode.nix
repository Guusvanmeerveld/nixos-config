{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.development.vscode; theme = config.custom.theme; in
{
  options = {
    custom.applications.graphical.development.vscode = {
      enable = lib.mkEnableOption "Enable VSCode development IDE";
    };
  };

  config = lib.mkIf cfg.enable {
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

        "terminal.integrated.cursorBlinking" = true;

        "editor.cursorBlinking" = "smooth";

        "nixEnvSelector.suggestion" = false;

        "git.confirmSync" = false;
        "git.autofetch" = true;
        "git.enableSmartCommit" = true;
        "git.openRepositoryInParentFolders" = "always";
        "git.autoStash" = true;

        "editor.formatOnSave" = true;
        "editor.fontFamily" = "'${theme.font.name}', 'MesloLGS NF', 'Droid Sans Mono', 'monospace', monospace";
        "editor.fontLigatures" = true;
        "editor.minimap.showSlider" = "always";

        "[typescriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };

        "[typescript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };

        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };

        "[scss]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };

        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };

        "spellright.notificationClass" = "warning";
        "spellright.configurationScope" = "user";
        "spellright.suggestionsInHints" = false;
        "spellright.language" = [ "en_US" "nl_NL" ];
      };

      extensions = with pkgs.vscode-extensions; [
        zhuangtongfa.material-theme
        jnoortheen.nix-ide
        # scalameta.metals
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
        bradlc.vscode-tailwindcss
        dbaeumer.vscode-eslint
        # ms-vscode.atom-keybindings
      ];
    };

    home.packages = with pkgs; [
      nixpkgs-fmt
      hunspell
      hunspellDicts.en_US
      hunspellDicts.nl_nl
    ];
  };

}
