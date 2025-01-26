{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.theming.gtk;
in {
  options = {
    custom.programs.theming.gtk = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.programs.theming.enable;
        description = "Enable GTK 3/4 theming";
      };

      theme = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "WhiteSur-Dark";
        };

        package = lib.mkPackageOption pkgs "whitesur-gtk-theme" {};
      };

      iconTheme = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "WhiteSur-dark";
        };

        package = lib.mkPackageOption pkgs "whitesur-icon-theme" {};
      };
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

          gtk-theme = cfg.theme.name;
          icon-theme = cfg.iconTheme.name;
        };

        "org/gnome/desktop/wm/preferences" = {
          theme = cfg.theme.name;
        };
      };
    };

    gtk = {
      enable = true;

      iconTheme = cfg.iconTheme;
      theme = cfg.theme;

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };
}
