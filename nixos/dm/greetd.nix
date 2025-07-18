{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.dm.greetd;
in {
  options = {
    custom.dm.greetd = {
      enable = lib.mkEnableOption "Enable greetd display manager";
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --issue --remember --time --cmd sway";
        };
      };
    };
  };
}
