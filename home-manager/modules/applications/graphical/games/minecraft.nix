{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.games.minecraft;
in {
  options = {
    custom.applications.graphical.games.minecraft = {
      enable = lib.mkEnableOption "Enable Minecraft launcher";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [prismlauncher];
  };
}
