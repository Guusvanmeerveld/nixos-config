{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.shell.zsh;
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
    home.packages = with pkgs; [zoxide nix-output-monitor];

    programs = {
      zsh = {
        enable = true;

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
        autosuggestion.enable = true;
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
          hms = "home-manager switch --flake ${config.custom.nixConfigLocation} -b backup";
          nbs = "nixos-rebuild switch --flake ${config.custom.nixConfigLocation} --use-remote-sudo --log-format internal-json -v |& nom --json";
          "nix build" = "nom build";

          edit = "$EDITOR";

          down = "poweroff";
          lsa = "ls -lah";
          rr = "reboot";

          ls = lib.mkIf config.programs.eza.enable "eza";

          s = lib.mkIf config.programs.kitty.enable "kitten ssh";

          code = lib.mkIf config.programs.vscode.enable "codium";
          nxvsc = lib.mkIf config.programs.vscode.enable "nix-shell --command 'codium .'";
          nxp = "nix-shell -p ";

          dc = "docker compose up -d";
          dcd = "docker compose down --remove-orphans";
          dcl = "docker compose logs -f";
        };

        oh-my-zsh = {
          enable = true;

          plugins = ["git" "sudo" "yarn" "vscode" "colorize" "zoxide"];
        };

        zplug = {
          enable = true;
          plugins = [
            {
              name = "chisui/zsh-nix-shell";
            }
          ];
        };
      };
    };
  };
}
