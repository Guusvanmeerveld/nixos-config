{
  lib,
  config,
  ...
}: let
  cfg = config.custom.virtualisation.waydroid;
in {
  options = {
    custom.virtualisation.waydroid = {
      enable = lib.mkEnableOption "Enable Android virtualisation software";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
  };
}
