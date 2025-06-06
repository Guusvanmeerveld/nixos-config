{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  cfg = config.custom.programs.tidal;

  package = pkgs.tidal-hifi;
in {
  imports = [outputs.homeManagerModules.tidal-hifi];

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

    programs.tidal-hifi = {
      enable = true;

      inherit package;

      settings = {
        mpris = true;
        api = false;
        menuBar = false;
        notifications = false;
        trayIcon = false;
      };
    };
  };
}
