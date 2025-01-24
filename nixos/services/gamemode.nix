{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.gamemode;
in {
  options = {
    custom.services.gamemode = {
      enable = lib.mkEnableOption "Enable Gamemode performance optimizer";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;

      settings = {
        general = {
          renice = 10;
        };
      };
    };
  };
}
