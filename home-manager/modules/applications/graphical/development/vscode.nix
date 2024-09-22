{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.development.vscode;

  vscodeVersion = config.programs.vscode.package.version;

  desktopFile = "codium.desktop";

  openByDefault = [
    "text/plain"
    "text/html"
    "text/css"
    "text/javascript"
    "text/typescript"
  ];
in {
  options = {
    custom.applications.graphical.development.vscode = {
      enable = lib.mkEnableOption "Enable VSCode development IDE";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = builtins.listToAttrs (map (mimeType: {
        name = mimeType;
        value = desktopFile;
      })
      openByDefault);

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

        "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
        "clangd.arguments" = [
          "--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
        ];

        "cmake.configureOnOpen" = false;
        "cmake.options.statusBarVisibility" = "hidden";
        "cmake.showOptionsMovedNotification" = false;

        "cmake.pinnedCommands" = [
          "workbench.action.tasks.configureTaskRunner"
          "workbench.action.tasks.runTask"
        ];
      };

      extensions =
        (with (pkgs.forVSCodeVersion vscodeVersion).vscode-marketplace; [
          ms-vscode-remote.remote-containers
        ])
        ++ (with (pkgs.forVSCodeVersion vscodeVersion).open-vsx; [
          # NixOS
          arrterian.nix-env-selector

          # Keybindings
          ms-vscode.atom-keybindings

          # Theme
          zhuangtongfa.material-theme
          pkief.material-icon-theme

          # Spelling
          ban.spellright

          # Tools
          jeanp413.open-remote-ssh
          james-yu.latex-workshop
          dbaeumer.vscode-eslint
          ms-vscode.cmake-tools
          esbenp.prettier-vscode

          # LSPs
          # ms-toolsai.jupyter
          ms-python.python
          muhammad-sammy.csharp
          llvm-vs-code-extensions.vscode-clangd
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
        ]);
    };

    home.packages = with pkgs; [
      hunspell
      hunspellDicts.en_US
      hunspellDicts.nl_nl
      nixd
      alejandra

      gnumake
      ninja
    ];
  };
}
