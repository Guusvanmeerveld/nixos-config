{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.games.default-apps;
in {
  options.custom.programs.games.default-apps.enable = lib.mkEnableOption "Enable default game launchers";

  config = lib.mkIf cfg.enable {
    custom.programs.games = {
      heroic.enable = lib.mkDefault true;
      minecraft.enable = lib.mkDefault true;
      mangohud.enable = lib.mkDefault true;
    };
  };
}
