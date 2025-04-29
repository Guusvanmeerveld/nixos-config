{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.cli.zsh;

  nh = lib.getExe pkgs.nh;
in {
  options = {
    custom.programs.cli.zsh = {
      enable = lib.mkEnableOption "Enable zsh shell";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [zoxide];

    programs = {
      zsh = {
        enable = true;

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
          hms = "${nh} home switch ${config.custom.nixConfigLocation}";
          nbs = "${nh} os switch ${config.custom.nixConfigLocation}";

          edit = "$EDITOR";

          down = "poweroff";
          lsa = "ls -lah";
          rr = "reboot";

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
