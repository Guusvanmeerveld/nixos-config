{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.gtk;

  inherit (lib) generators;

  gtk3SettingsFormat =
    generators.toINI {};

  gtk3-cfg = {
    "Settings" = {
      gtk-theme-name = cfg.theme.name;
    };
  };
  # // cfg.gtk3.extraConfig;
in {
  options = {
    gtk = {
      enable = lib.mkEnableOption "Enable gtk theming";

      theme = {
        name = lib.mkOption {
          type = lib.types.str;
        };

        package = lib.mkPackageOption pkgs "hello" {};
      };

      gtk3 = {
        extraConfig = lib.mkOption {
          type = lib.types.submodule;
          default = {};
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.etc."xdg/gtk-2.0/gtkrc".source = ''
    #   gtk-key-theme-name = "Emacs"
    # '';

    environment.systemPackages = [cfg.theme.package];

    environment.etc."gtk-3.0/settings.ini".text = gtk3SettingsFormat gtk3-cfg;
  };
}
