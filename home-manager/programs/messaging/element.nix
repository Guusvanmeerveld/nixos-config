{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.element;
in {
  options = {
    custom.programs.messaging.element = {
      enable = lib.mkEnableOption "Enable Element matrix client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      element-desktop
    ];
  };
}
