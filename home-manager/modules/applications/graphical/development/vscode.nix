{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.development.vscode;
  theme = config.custom.wm.theme;
in {
  options = {
    custom.applications.graphical.development.vscode = {
      enable = lib.mkEnableOption "Enable VSCode development IDE";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      mutableExtensionsDir = false;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      userSettings = {
        "window.zoomLevel" = 1;

        # Privacy
        "telemetry.telemetryLevel" = "off";
        "security.workspace.trust.enabled" = false;

        # Set themes
        "workbench.colorTheme" = "One Dark Pro";
        "workbench.iconTheme" = "material-icon-theme";

        "nixEnvSelector.suggestion" = false;

        # Git integration config
        "git.confirmSync" = false;
        "git.autofetch" = true;
        "git.enableSmartCommit" = true;
        "git.openRepositoryInParentFolders" = "always";
        "git.autoStash" = true;

        # Editor config
        "editor.formatOnSave" = true;
        "editor.fontLigature" = true;
        "editor.fontFamily" = "'${theme.font.name}', 'MesloLGS NF', 'Droid Sans Mono', 'monospace', monospace";
        "editor.minimap.showSlider" = "always";
        "editor.inlayHints.enabled" = "offUnlessPressed";
        "editor.cursorBlinking" = "smooth";

        # Explorer config
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;

        # Integrated terminal config
        "terminal.integrated.cursorBlinking" = true;

        # Language specific
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

        "[nix]" = {
          "editor.defaultFormatter" = "kamadorueda.alejandra";
        };

        "alejandra.program" = "alejandra";

        "nix" = {
          "enableLanguageServer" = true;
          "serverPath" = "nil";
          "serverSettings" = {
            "nil" = {
              "flake" = {
                "autoEvalInputs" = true;
              };
            };
          };
        };

        "spellright.notificationClass" = "warning";
        "spellright.configurationScope" = "user";
        "spellright.suggestionsInHints" = false;
        "spellright.language" = ["en_US" "nl_NL"];
      };

      extensions = with pkgs.vscode-marketplace;
        [
          zhuangtongfa.material-theme
          jnoortheen.nix-ide
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
          # ms-dotnettools.csharp
          # ms-vscode-remote.remote-ssh
          ms-vscode.atom-keybindings
        ]
        ++ (with pkgs.open-vsx; [jeanp413.open-remote-ssh muhammad-sammy.csharp kamadorueda.alejandra]);
    };

    home.packages = with pkgs; [
      nixpkgs-fmt
      hunspell
      hunspellDicts.en_US
      hunspellDicts.nl_nl
      nil
      alejandra
    ];
  };
}
