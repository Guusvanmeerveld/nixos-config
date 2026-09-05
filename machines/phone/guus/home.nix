{lib, ...}: {
  imports = [
    (lib.custom.relativeToRoot "home-manager")
  ];

  custom.programs.cli.default-apps.enable = true;

  home.stateVersion = "24.05";
}
