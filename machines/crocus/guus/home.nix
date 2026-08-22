{...}: {
  imports = [
    ../../../home-manager
  ];

  custom.programs.cli.default.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
