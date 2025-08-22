{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.playerctld;
in {
  options = {
    custom.services.playerctld = {
      enable = lib.mkEnableOption "Enable playerctld";
    };
  };

  config = lib.mkIf cfg.enable {
    services.playerctld = {
      enable = true;
    };
  };
}
