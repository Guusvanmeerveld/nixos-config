{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.shell.eza;
in {
  options = {
    custom.applications.shell.eza = {
      enable = lib.mkEnableOption "Enable Eza ls replacement";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      icons = true;
      git = true;
    };

    home.packages = lib.mkIf config.programs.eza.icons (with pkgs; [font-awesome]);
  };
}
