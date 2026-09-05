{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.office.default-apps;
in {
  options.custom.programs.office.default-apps.enable = lib.mkEnableOption "Enable default office applications";

  config = lib.mkIf cfg.enable {
    custom.programs.office = {
      gimp.enable = lib.mkDefault true;
      libreoffice.enable = lib.mkDefault true;
      teams.enable = lib.mkDefault true;
      trilium-desktop.enable = lib.mkDefault true;
    };
  };
}
