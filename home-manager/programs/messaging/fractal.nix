{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.fractal;

  package = pkgs.fractal;
in {
  options = {
    custom.programs.messaging.fractal = {
      enable = lib.mkEnableOption "Enable Fractal Matrix client";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway.config = {
      assigns."1" = [
        {
          app_id = "^org.gnome.Fractal$";
        }
      ];

      keybindings = {
        "${config.wayland.windowManager.sway.config.modifier}+b" =
          pkgs.custom.scripts.swayFocusOrStart "org.gnome.Fractal" (lib.getExe package);
      };
    };

    home.packages = [
      package
    ];
  };
}
