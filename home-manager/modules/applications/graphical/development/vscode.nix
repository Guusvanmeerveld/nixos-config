{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.development.vscode;
  vscodeVersion = config.programs.vscode.package.version;
in {
  options = {
    custom.applications.graphical.development.vscode = {
      enable = lib.mkEnableOption "Enable VSCode development IDE";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscodium;

      mutableExtensionsDir = false;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      userSettings = let
        fonts = map (font: "'${font.name}'") config.custom.applications.graphical.theming.font.default;
      in {
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
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "${lib.concatStringsSep ", " fonts},  'Droid Sans Mono', monospace";
        "editor.minimap.showSlider" = "always";
        "editor.inlayHints.enabled" = "offUnlessPressed";
        "editor.cursorBlinking" = "smooth";

        # Explorer config
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;

        "update.showReleaseNotes" = false;
        "workbench.startupEditor" = "none";

        # Integrated terminal config
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.showExitAlert" = false;

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
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          nixd = {
            formatting = {
              command = ["alejandra"];
            };
          };
        };

        "spellright.notificationClass" = "warning";
        "spellright.configurationScope" = "user";
        "spellright.suggestionsInHints" = false;
        "spellright.language" = ["en-US-10-1."];

        "jupyter.experiments.enabled" = false;
        "jupyter.themeMatplotlibPlots" = true;

        "latex-workshop.latex.outDir" = "%DIR%/out";
      };

      extensions =
        (with (pkgs.forVSCodeVersion vscodeVersion).vscode-marketplace; [
          # Theme
          zhuangtongfa.material-theme
          pkief.material-icon-theme

          # Keybindings
          ms-vscode.atom-keybindings

          # NixOS
          arrterian.nix-env-selector

          # LSPs
          jnoortheen.nix-ide
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
          redhat.java
          vscjava.vscode-maven
          vscjava.vscode-java-debug
          vscjava.vscode-java-dependency
          vadimcn.vscode-lldb
          bradlc.vscode-tailwindcss
          prince781.vala

          ms-dotnettools.vscode-dotnet-runtime

          # Tools
          esbenp.prettier-vscode
          dbaeumer.vscode-eslint
          james-yu.latex-workshop

          ms-vscode-remote.remote-containers

          # Spelling
          ban.spellright
        ])
        ++ (with (pkgs.forVSCodeVersion vscodeVersion).open-vsx; [
          jeanp413.open-remote-ssh
          # Tools

          # ms-toolsai.jupyter
          ms-python.python
          # LSPs
          muhammad-sammy.csharp
        ]);
    };

    home.packages = with pkgs; [
      hunspell
      hunspellDicts.en_US
      hunspellDicts.nl_nl
      nixd
      alejandra
    ];
  };
}
