{...}: {
  imports = [
    ../../../home-manager
  ];

  custom = {
    services = {
      syncthing.enable = true;
      vscode-server.enable = true;
    };

    programs.cli = {
      default.enable = true;
      atuin = {
        enable = true;
        server = "https://atuin.guusvanmeerveld.dev";
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
