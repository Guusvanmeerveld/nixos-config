{...}: {
  imports = [
    ../../home-manager/modules
  ];

  home = {
    username = "guus";
    homeDirectory = "/home/guus";
  };

  custom = {
    applications = {
      services = {
        syncthing.enable = true;
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
