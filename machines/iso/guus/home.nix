{pkgs, ...}: {
  imports = [
    ../../../home-manager
  ];

  home.packages = with pkgs; [perl];

  custom.programs.cli = {
    default.enable = true;
    atuin.enable = false;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
