{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.office;
in {
  imports = [./gimp.nix ./libreoffice.nix ./teams.nix ./latex.nix];

  options = {
    custom.programs.office = {
      enable = lib.mkEnableOption "Enable default office applications";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.office = {
      gimp.enable = true;
      libreoffice.enable = true;
      latex.enable = true;
    };
  };
}
