{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.games.minecraft;
in {
  options = {
    custom.programs.games.minecraft = {
      enable = lib.mkEnableOption "Enable Minecraft launcher";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [prismlauncher jdk21];
  };
}
