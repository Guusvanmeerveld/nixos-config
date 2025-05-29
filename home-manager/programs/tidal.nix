{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.tidal;

  package = pkgs.tidal-hifi;
in {
  options = {
    custom.programs.tidal = {
      enable = lib.mkEnableOption "Enable Tidal music application";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway.config = {
      assigns."2" = [
        {
          app_id = "^tidal-hifi$";
        }
      ];
      keybindings = {
        "${config.wayland.windowManager.sway.config.modifier}+x" =
          pkgs.custom.scripts.swayFocusOrStart "tidal-hifi" (lib.getExe package);
      };
    };

    home.packages = [package];
  };
}
