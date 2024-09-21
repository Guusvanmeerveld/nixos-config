{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.loupe;
  desktopFile = "org.gnome.Loupe.desktop";
in {
  options = {
    custom.applications.graphical.loupe = {
      enable = lib.mkEnableOption "Enable Loupe image viewer program";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [loupe];

    xdg.mimeApps = {
      defaultApplications = {
        "image/jpeg" = [desktopFile];
        "image/png" = [desktopFile];
        "image/gif" = [desktopFile];
        "image/bmp" = [desktopFile];
        "image/tiff" = [desktopFile];
        "image/webp" = [desktopFile];
        "image/svg+xml" = [desktopFile];
        "image/x-icon" = [desktopFile];
      };
    };
  };
}
