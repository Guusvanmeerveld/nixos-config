{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.development.vscode;

  vscodeVersion = config.programs.vscode.package.version;

  desktopFile = "codium.desktop";

  openByDefault = [
    "text/plain"
    "text/html"
    "text/css"
    "text/javascript"
    "text/typescript"
  ];

  spellCheckLanguages = with pkgs; [
    {
      name = "nl_NL";
      package = hunspellDicts.nl_nl;
    }
    {
      name = "en_US";
      package = hunspellDicts.en_US;
    }
  ];

  configDirName = "VSCodium";
in {
  options = {
    custom.programs.development.vscode = {
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
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "'${config.custom.programs.theming.font.monospace.name}', monospace";
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

        "[latex]" = {
          "editor.defaultFormatter" = "James-Yu.latex-workshop";
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
        "spellright.documentTypes" = ["markdown" "latex" "plaintext"];
        "spellright.language" = map (language: language.name) spellCheckLanguages;

        "jupyter.experiments.enabled" = false;
        "jupyter.themeMatplotlibPlots" = true;

        "latex-workshop.latex.outDir" = "%DIR%/out";
        "latex-workshop.formatting.latex" = "latexindent";

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

        "sqlfluff.dialect" = "duckdb";

        "tabby.endpoint" = "http://localhost:11029";
        "tabby.config.telemetry" = true;
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

          jeff-hykin.better-shellscript-syntax

          # Text writing
          ban.spellright
          carlocardella.vscode-texttoolbox

          # Tools
          jeanp413.open-remote-ssh
          james-yu.latex-workshop
          dbaeumer.vscode-eslint
          timonwong.shellcheck
          ms-vscode.cmake-tools
          esbenp.prettier-vscode
          tabbyml.vscode-tabby
          mkhl.direnv

          # LSPs
          # ms-toolsai.jupyter
          # ms-python.python
          sqlfluff.vscode-sqlfluff
          twxs.cmake
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
          golang.go
          mads-hartmann.bash-ide-vscode
        ]);
    };

    # Link hunspell dictionaries to correct dir.
    xdg.configFile = lib.mkMerge [
      (lib.listToAttrs (map (language: {
          name = "${configDirName}/Dictionaries/${language.name}.dic";
          value = {
            source = "${language.package}/share/hunspell/${language.name}.dic";
          };
        })
        spellCheckLanguages))

      (lib.listToAttrs (map (language: {
          name = "${configDirName}/Dictionaries/${language.name}.aff";
          value = {
            source = "${language.package}/share/hunspell/${language.name}.aff";
          };
        })
        spellCheckLanguages))
    ];

    home.packages = with pkgs; [
      ninja
      cmake
      gnumake

      # Nix IDE
      alejandra
      nixd

      go

      sqlfluff
    ];
  };
}
