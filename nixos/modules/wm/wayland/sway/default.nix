{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;

  package =
    if cfg.useFx
    then pkgs.swayfx
    else pkgs.sway;
in {
  imports = [./osd.nix];

  options = {
    custom.wm.wayland.sway = {
      enable = lib.mkEnableOption "Enable sway window manager";

      useFx = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.default = {
      name = "sway";
      path = lib.getExe package;
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    security.pam.services.swaylock = {};
  };
}
