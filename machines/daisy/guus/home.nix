{...}: {
  imports = [
    ../../../home-manager
  ];

  custom = {
    programs.cli = {
      atuin.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      starship.enable = true;
      git.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
