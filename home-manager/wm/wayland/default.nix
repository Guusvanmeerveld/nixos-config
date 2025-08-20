{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config. custom.wm.wayland;
in {
  imports = [./sway ./cliphist.nix];

  options = {
    custom.wm.wayland = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.sway.enable;
        description = "Enable Wayland";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [wdisplays];

    custom.programs.wayland-screenshot.enable = true;
  };
}
