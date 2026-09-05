{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.signal;

  package = pkgs.signal-desktop;
in {
  options = {
    custom.programs.messaging.signal = {
      enable = lib.mkEnableOption "Enable Signal client";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit package;
        appId = "signal";
        keybind = "$mod+b";
        workspace = 1;
      }
    ];

    home.packages = [
      package
    ];
  };
}
