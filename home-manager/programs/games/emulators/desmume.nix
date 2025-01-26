{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.games.emulators.desmume;
in {
  options = {
    custom.programs.games.emulators.desmume = {
      enable = lib.mkEnableOption "Enable Desmume Open-source Nintendo DS emulator";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [desmume];
  };
}
