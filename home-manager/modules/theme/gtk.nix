{ lib, config, pkgs, ... }:
let cfg = config.custom.theme.gtk; in
{
  options = {
    custom.theme.gtk = {
      enable = lib.mkEnableOption "Enable GTK 3/4 theming";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      dconf
    ];

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };

    gtk = {
      enable = true;

      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };

      cursorTheme = {
        name = "macOS-BigSur";
        package = pkgs.apple-cursor;
        size = 2;
      };

      theme = {
        name = "Fluent-Dark";
        package = pkgs.fluent-gtk-theme;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };
}
