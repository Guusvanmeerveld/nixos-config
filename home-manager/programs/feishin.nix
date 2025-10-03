{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.feishin;

  package = pkgs.feishin;
in {
  options = {
    custom.programs.feishin = {
      enable = lib.mkEnableOption "Enable Feishin jellyfin music client";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit package;
        workspace = 2;
        appId = "feishin";
        keybind = "$mod+x";
      }
    ];

    home.packages = [package];
  };
}
