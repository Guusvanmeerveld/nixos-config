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
    custom.wm.applications = [
      {
        inherit package;
        workspace = 2;
        appId = "tidal-hifi";
        keybind = "$mod+x";
      }
    ];

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
