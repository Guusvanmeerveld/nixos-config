{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.office.teams;
in {
  options = {
    custom.programs.office.teams = {
      enable = lib.mkEnableOption "Enable Microsoft Teams for Linux";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [teams-for-linux];
  };
}
