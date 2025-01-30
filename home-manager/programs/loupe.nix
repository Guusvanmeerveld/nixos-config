{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.loupe;

  desktopFile = "org.gnome.Loupe.desktop";

  openByDefault = [
    "image/png"
    "image/jpeg"
    "image/jpg"
    "image/gif"
    "image/bmp"
    "image/tiff"
    "image/webp"
    "image/svg+xml"
    "image/x-icon"
  ];
in {
  options = {
    custom.programs.loupe = {
      enable = lib.mkEnableOption "Enable Loupe image viewer program";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [loupe];

    xdg.mimeApps = {
      defaultApplications = builtins.listToAttrs (map (mimeType: {
          name = mimeType;
          value = desktopFile;
        })
        openByDefault);
    };
  };
}
