{ config, pkgs, ... }:

let
  p10kTheme = ./p10k.zsh;
in
{
  home.packages = with pkgs; [ zoxide thefuck ];

  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        sync_address = "https://atuin.guusvanmeerveld.dev";
        auto_sync = true;
        sync_frequency = "5m";
        search_mode = "prefix";
        enter_accept = false;
      };
    };

    zsh = {
      initExtra = ''
        [[ ! -f ${p10kTheme} ]] || source ${p10kTheme}
      '';

      enable = true;

      sessionVariables = {
        EDITOR = "nvim";
      };

      shellAliases = {
        hms = "home-manager switch --flake ~/nix/config -b backup";
        nbs = "sudo nixos-rebuild switch --flake ~/nix/config";

        down = "poweroff";
        lsa = "ls -ah";
        rr = "reboot";

        code = "codium";
      };

      oh-my-zsh = {
        enable = true;

        plugins = [ "git" "sudo" "yarn" "vscode" "colorize" ];
      };

      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
          { name = "ajeetdsouza/zoxide"; }
          { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
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
}
