{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  p10kTheme = ./p10k.zsh;
  cfg = config.custom.applications.shell.zsh;
  shell = config.custom.applications.shell;
in {
  imports = [inputs.nix-index-database.hmModules.nix-index];

  options = {
    custom.applications.shell.zsh = {
      enable = lib.mkEnableOption "Enable zsh shell";

      editor = lib.mkOption {
        type = lib.types.str;
        description = "The editor to use by default";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [zoxide thefuck meslo-lgs-nf];

    programs = {
      nix-index.enable = true;

      zsh = {
        initExtra = ''
          [[ ! -f ${p10kTheme} ]] || source ${p10kTheme}
        '';

        enable = true;

        sessionVariables = {
          EDITOR = cfg.editor;
          NIX_CONFIG_LOCATION = "${config.home.homeDirectory}/nix/config";
        };

        shellAliases = {
          hms = "home-manager switch --flake $NIX_CONFIG_LOCATION -b backup";
          nbs = "sudo nixos-rebuild switch --flake $NIX_CONFIG_LOCATION";

          edit = "$EDITOR";

          down = "poweroff";
          lsa = "ls -ah";
          rr = "reboot";

          ls = lib.mkIf shell.eza.enable "eza";

          code = "codium";
          nxvsc = "nix-shell --command 'codium .'";
          nxp = "nix-shell -p ";

          dc = "docker compose up -d";
          dcd = "docker compose down --remove-orphans";
        };

        oh-my-zsh = {
          enable = true;

          plugins = ["git" "sudo" "yarn" "vscode" "colorize"];
        };

        zplug = {
          enable = true;
          plugins = [
            {name = "zsh-users/zsh-autosuggestions";}
            {name = "zsh-users/zsh-syntax-highlighting";}
            {name = "ajeetdsouza/zoxide";}
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
        ];
      };
    };
  };
}
