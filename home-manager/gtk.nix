{ config, pkgs, lib, ... }:

{
  gtk = {
    enable = true;

    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };

    cursorTheme = {
      name = "macOS-BigSur";
      package = pkgs.apple-cursor;
      size = 2;
    };

    theme =
      {
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
}
