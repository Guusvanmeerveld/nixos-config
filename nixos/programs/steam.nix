{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.steam;
in {
  options = {
    custom.programs.steam = {
      enable = lib.mkEnableOption "Enable Steam game launcher application";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;

      protontricks.enable = true;

      package = pkgs.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            gamemode
            gamescope
          ];
      };
    };

    hardware.steam-hardware.enable = true;
  };
}
