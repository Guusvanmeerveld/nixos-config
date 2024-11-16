{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.gamemode;
in {
  options = {
    custom.applications.services.gamemode = {
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
