{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.gvfs;
in {
  options = {
    custom.services.gvfs.enable = lib.mkEnableOption "Enable GVFS virtual fs";
  };

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
  };
}
