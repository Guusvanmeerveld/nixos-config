{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.tauon;

  package = pkgs.tauon;
in {
  options = {
    custom.programs.tauon = {
      enable = lib.mkEnableOption "Enable Tauon music application";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit package;
        workspace = 2;
        appId = "tauonmb";
        keybind = "$mod+x";
      }
    ];

    home.packages = [package];
  };
}
