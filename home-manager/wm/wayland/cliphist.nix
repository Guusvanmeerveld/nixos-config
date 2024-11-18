{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.cliphist;

  menu = pkgs.writeShellApplication {
    name = "cliphist-menu";

    runtimeInputs = with pkgs; [unstable.nwg-clipman wl-clipboard];

    text = ''
      nwg-clipman
    '';
  };
in {
  options = {
    custom.wm.wayland.cliphist = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.enable;
        description = "Enable cliphist clipboard manager";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [menu];

    services.cliphist = {
      enable = true;

      systemdTarget = "sway-session.target";
    };
  };
}
