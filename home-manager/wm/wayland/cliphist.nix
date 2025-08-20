{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.cliphist;

  package = pkgs.clipman;
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
    custom.wm.applications = [
      {
        keybind = "Ctrl+Alt+v";
        executable = lib.getExe package;
      }
    ];

    home.packages = [package];

    services.cliphist.enable = true;
  };
}
