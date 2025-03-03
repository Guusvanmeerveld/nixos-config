{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.games.emulators.suyu;
in {
  options = {
    custom.programs.games.emulators.suyu = {
      enable = lib.mkEnableOption "Enable Suyu Open-source Nintendo switch emulator";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [suyu];
  };
}
