{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.office.teams; in
{
  options = {
    custom.applications.graphical.office.teams = {
      enable = lib.mkEnableOption "Enable Microsoft Teams for Linux";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ teams-for-linux ];
  };
}

