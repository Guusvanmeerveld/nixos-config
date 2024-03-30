{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.thunar; in
{
  options = {
    custom.applications.graphical.thunar = {
      enable = lib.mkEnableOption "Enable Thunar file explorer";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ xfce.thunar ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "thunar.desktop" ];
      };
    };
  };
}
