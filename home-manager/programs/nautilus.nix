{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.nautilus;

  package = pkgs.nautilus;
in {
  options = {
    custom.programs.nautilus = {
      enable = lib.mkEnableOption "Enable Nautilus file explorer";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit package;
        keybind = "$mod+e";
        appId = "org.gnome.Nautilus";
      }
    ];

    home.packages = [
      package
    ];

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = ["org.gnome.Nautilus.desktop"];
    };
  };
}
