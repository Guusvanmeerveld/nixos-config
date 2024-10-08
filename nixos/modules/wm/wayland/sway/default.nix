{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;
in {
  imports = [./osd.nix];

  options = {
    custom.wm.wayland.sway = {
      enable = lib.mkEnableOption "Enable sway window manager";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.default = {
      name = "sway";
      path = "${pkgs.sway}/bin/sway";
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    security.pam.services.swaylock = {};
  };
}
