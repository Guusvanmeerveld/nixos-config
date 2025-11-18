{...}: {
  imports = [
    ../../../home-manager
  ];

  custom = {
    services = {
      vscode-server.enable = true;
    };

    programs.cli = {
      default.enable = true;

      gpg.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
