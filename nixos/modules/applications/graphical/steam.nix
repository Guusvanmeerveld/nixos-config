{ lib, config, ... }:
let
  cfg = config.custom.applications.graphical.steam;
in
{
  options = {
    custom.applications.graphical.steam = {
      enable = lib.mkEnableOption "Enable Steam game launcher application";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    hardware.steam-hardware.enable = true;

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
    ];
  };
}
