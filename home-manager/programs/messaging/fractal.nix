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
    custom.wm.applications = [
      {
        inherit package;
        appId = "org.gnome.Fractal";
        keybind = "$mod+b";
        workspace = 1;
      }
    ];

    home.packages = [
      package
    ];
  };
}
