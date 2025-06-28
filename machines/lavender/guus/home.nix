{pkgs, ...}: {
  imports = [
    ../../../home-manager
  ];

  home.packages = with pkgs; [libraspberrypi raspberrypi-eeprom i2c-tools];

  custom = {
    services = {
      vscode-server.enable = true;
    };

    programs.cli = {
      default.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
