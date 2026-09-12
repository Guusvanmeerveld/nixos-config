{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.theming.gtk;
in {
  options = {
    custom.programs.theming.gtk = let
      defaultGtkOptions = config.custom.shared.theming.gtk;
    in {
      enable = lib.mkEnableOption "Enable GTK 3/4 theming";

      theme = {
        name = lib.mkOption {
          type = lib.types.str;
          default = defaultGtkOptions.theme.name;
        };

        package = lib.mkOption {
          default = defaultGtkOptions.theme.package;
          type = lib.types.package;
        };
      };

      iconTheme = {
        name = lib.mkOption {
          type = lib.types.str;
          default = defaultGtkOptions.iconTheme.name;
        };

        package = lib.mkOption {
          default = defaultGtkOptions.iconTheme.package;
          type = lib.types.package;
        };
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

      inherit (cfg) iconTheme;
      inherit (cfg) theme;

      gtk4.theme = null;

      colorScheme = "dark";
    };
  };
}
