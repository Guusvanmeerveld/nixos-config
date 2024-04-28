{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.shell.zsh;
  shell = config.custom.applications.shell;
in {
  options = {
    custom.applications.shell.zsh = {
      enable = lib.mkEnableOption "Enable zsh shell";

      editor = lib.mkOption {
        type = lib.types.str;
        default = "vi";
        description = "The editor to use by default";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [zoxide meslo-lgs-nf nix-output-monitor];

    programs = {
      zsh = {
        enable = true;

        initExtraBeforeCompInit = ''
          local P10K_INSTANT_PROMPT="${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
          [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
        '';

        initExtra = ''
          if [ "$TERM_PROGRAM" = "vscode" ]
          then
              export EDITOR=codium
          else
              export EDITOR=${cfg.editor}
          fi

          bindkey '^H' backward-kill-word
        '';

        dotDir = ".config/zsh";
        enableAutosuggestions = true;
        syntaxHighlighting.enable = true;

        history = {
          size = 1000000;
          save = 1000000;
          ignoreSpace = false;
        };

        sessionVariables = {
          NIX_CONFIG_LOCATION = config.custom.nixConfigLocation;
        };

        shellAliases = {
          hms = "home-manager switch --flake $NIX_CONFIG_LOCATION -b backup";
          nbs = "sudo nixos-rebuild switch --flake $NIX_CONFIG_LOCATION --log-format internal-json -v |& nom --json";
          "nix build" = "nom build";

          edit = "$EDITOR";

          down = "poweroff";
          lsa = "ls -ah";
          rr = "reboot";

          ls = lib.mkIf config.programs.eza.enable "eza";

          code = lib.mkIf config.programs.vscode.enable "codium";
          nxvsc = lib.mkIf config.programs.vscode.enable "nix-shell --command 'codium .'";
          nxp = "nix-shell -p ";

          dc = "docker compose up -d";
          dcd = "docker compose down --remove-orphans";
        };

        oh-my-zsh = {
          enable = true;

          plugins = ["git" "sudo" "yarn" "vscode" "colorize" "zoxide"];
        };

        zplug = {
          enable = true;
          plugins = [
            {name = "chisui/zsh-nix-shell";}
            {
              name = "romkatv/powerlevel10k";
              tags = [as:theme depth:1];
            }
          ];
        };

        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            file = "p10k.zsh";
            src = ./.;
          }
        ];
      };
    };
  };
}
