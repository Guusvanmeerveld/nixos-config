{ lib, config, ... }:
let
  cfg = config.custom.applications.graphical.office;
in
{
  imports = [ ./gimp.nix ./libreoffice.nix ./teams.nix ./latex.nix ];

  options = {
    custom.applications.graphical.office = {
      enable = lib.mkEnableOption "Enable default office applications";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.office = {
      gimp.enable = true;
      libreoffice.enable = true;
      latex.enable = true;
    };
  };
}
