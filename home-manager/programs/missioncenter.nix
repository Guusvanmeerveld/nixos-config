{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.missioncenter;

  package = pkgs.mission-center;
in {
  options = {
    custom.programs.missioncenter = {
      enable = lib.mkEnableOption "Enable Mission center system monitor";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit package;
        appId = "io.missioncenter.MissionCenter";
        keybind = "$mod+q";
      }
    ];

    home.packages = [
      package
    ];
  };
}
