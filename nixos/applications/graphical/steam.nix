{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.steam;
in {
  options = {
    custom.applications.graphical.steam = {
      enable = lib.mkEnableOption "Enable Steam game launcher application";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;

      package = pkgs.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            gamemode
          ];
      };
    };

    hardware.steam-hardware.enable = true;

    allowedUnfree = [
      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"
    ];
  };
}
