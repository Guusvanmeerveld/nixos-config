{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.messaging.element;
in {
  options = {
    custom.applications.graphical.messaging.element = {
      enable = lib.mkEnableOption "Enable Element matrix client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      element-desktop
    ];
  };
}
