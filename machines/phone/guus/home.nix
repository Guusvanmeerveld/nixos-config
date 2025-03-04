{...}: {
  imports = [
    ../../../home-manager
  ];

  custom = {
    programs.cli.default.enable = true;
  };

  home.stateVersion = "24.05";
}
