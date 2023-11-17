{ config, pkgs, ... }:

let
  p10kTheme = ./p10k.zsh;
in
{
  programs.zsh = {
    initExtra = ''
      [[ ! -f ${p10kTheme} ]] || source ${p10kTheme}
    '';

    enable = true;

    sessionVariables = {
      EDITOR = "nvim";
    };

    shellAliases = {
      hms = "home-manager switch --flake ~/nixos-config";
      nbs = "sudo nixos-rebuild switch --flake ~/nixos-config";

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
}
