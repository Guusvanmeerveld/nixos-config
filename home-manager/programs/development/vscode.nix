{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.development.vscode;

  vscodeVersion = config.programs.vscode.package.version;

  compatibleExtensions = pkgs.forVSCodeVersion vscodeVersion;

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
    custom.programs.development.vscode = {
      enable = lib.mkEnableOption "Enable VSCode development IDE";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit (config.programs.vscode) package;
        appId = "codium";
        keybind = "$mod+d";
        workspace = 4;
      }
    ];

    xdg.mimeApps.defaultApplications = builtins.listToAttrs (map (mimeType: {
        name = mimeType;
        value = desktopFile;
      })
      openByDefault);

    programs = {
      zsh = {
        shellAliases = {
          code = "codium";
          nxvsc = "nix-shell --command 'codium .'";
        };
      };

      vscode = {
        enable = true;
        package = pkgs.vscodium;

        mutableExtensionsDir = false;

        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;

          userSettings = {
            "window.zoomLevel" = 1;

            # Privacy
            "telemetry.telemetryLevel" = "off";
            "telemetry.feedback.enabled" = false;
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

            "[jsonc]" = {
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
            "nix.hiddenLanguageServerErrors" = ["textDocument/formatting"];

            "cSpell.enabledFileTypes" = {"*" = true;};
            "cSpell.customDictionaries" = {
              "custom" = {
                "name" = "custom";
                "path" = "~/.config/dictionaries/vscode-words.txt";
                "scope" = "user";
                "addWords" = true;
              };
            };

            "jupyter.experiments.enabled" = false;
            "jupyter.themeMatplotlibPlots" = true;

            "latex-workshop.latex.outDir" = "%DIR%/out";
            "latex-workshop.formatting.latex" = "latexindent";
            "latex-workshop.message.error.show" = false;
            "latex-workshop.message.warning.show" = false;

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

            "java.jdt.ls.java.home" = "${pkgs.openjdk}/lib/openjdk";

            "metals.javaHome" = "${pkgs.openjdk}/lib/openjdk";
            "metals.metalsJavaHome" = "${pkgs.openjdk}/lib/openjdk";
            "metals.mavenScript" = lib.getExe pkgs.maven;
            "metals.millScript" = lib.getExe pkgs.mill;
            "metals.sbtScript" = "${pkgs.sbt}/bin/sbt";

            "python.defaultInterpreterPath" = lib.getExe pkgs.python3;

            "direnv.restart.automatic" = true;

            "razor.languageServer.directory" = "${pkgs.rzls}/lib/rzls";
            "dotnet.server.path" = "${pkgs.omnisharp-roslyn}/lib/omnisharp-roslyn/OmniSharp.dll";

            "dev.containers.dockerComposePath" = "${lib.getExe pkgs.docker} compose";
            "dev.containers.dockerPath" = lib.getExe pkgs.docker;

            "files.watcherExclude" = {
              "**/.bloop" = true;
              "**/.metals" = true;
              "**/target" = true;
            };
          };

          extensions =
            (with pkgs.vscode-extensions; [
              ms-vscode-remote.remote-containers
            ])
            ++ (with compatibleExtensions.vscode-marketplace; [
              eww-yuck.yuck

              allenli1231.zeppelin-vscode
            ])
            ++ (with compatibleExtensions.open-vsx; [
              ms-azuretools.vscode-docker
              # Keybindings
              ms-vscode.atom-keybindings

              # Theme
              zhuangtongfa.material-theme
              pkief.material-icon-theme

              jeff-hykin.better-shellscript-syntax

              # Text writing
              streetsidesoftware.code-spell-checker
              carlocardella.vscode-texttoolbox

              # Tools
              jeanp413.open-remote-ssh
              dbaeumer.vscode-eslint
              timonwong.shellcheck
              ms-vscode.cmake-tools
              esbenp.prettier-vscode
              tabbyml.vscode-tabby
              mkhl.direnv
              eamodio.gitlens
              ms-dotnettools.vscode-dotnet-runtime

              # Syntax
              scala-lang.scala

              # LSPs
              scalameta.metals
              ms-python.python
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
              # vadimcn.vscode-lldb
              bradlc.vscode-tailwindcss
              prince781.vala
              golang.go
              mads-hartmann.bash-ide-vscode
              james-yu.latex-workshop
              prisma.prisma
            ]);
        };
      };
    };

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
