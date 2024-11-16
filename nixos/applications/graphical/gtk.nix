{
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.gtk;
in {
  imports = [outputs.nixosModules.gtk];

  options = {
    custom.applications.graphical.gtk = {
      enable = lib.mkEnableOption "Enable gtk theming";
    };
  };

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;

      theme = {
        name = "Fluent-Dark";
        package = pkgs.fluent-gtk-theme;
      };
    };
  };
}
