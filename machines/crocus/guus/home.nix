{...}: {
  imports = [
    ../../../home-manager
  ];

  custom = {
    applications = {
      services = {
        vscode-server.enable = true;
      };

      shell = {
        default.enable = true;
        atuin = {
          enable = true;
          server = "https://atuin.guusvanmeerveld.dev";
        };
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
