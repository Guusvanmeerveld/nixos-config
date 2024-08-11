{pkgs, config, ...}: {
  imports = [
    ../../../home-manager/modules

    ./agenix.nix
    ./spotifyd.nix
  ];

  home = {
    username = "guus";
    homeDirectory = "/home/guus";
  };

  programs.kitty.enable = true;

  home.packages = with pkgs; [libraspberrypi raspberrypi-eeprom i2c-tools];

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
