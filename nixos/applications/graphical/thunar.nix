{
  config,
  lib,
  ...
}: let
  cfg = config.custom.applications.graphical;
in {
  options = {
    custom.applications.graphical.thunar.enable = lib.mkEnableOption "Enable Thunar file manager";
  };

  config = lib.mkIf cfg.thunar.enable {
    programs.thunar.enable = true;
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
  };
}
