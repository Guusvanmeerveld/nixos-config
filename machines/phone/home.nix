{...}: {
  imports = [
    ../../home-manager
  ];

  custom = {
    applications = {
      shell = {
        default.enable = true;

        atuin = {
          enable = true;
          server = "https://atuin.guusvanmeerveld.dev";
        };
      };
    };
  };

  home.stateVersion = "24.05";
}
