{
  lib,
  config,
  ...
}: let
  cfg = config.custom.de.noctalia;
in {
  options = {
    custom.de.noctalia = {
      enable = lib.mkEnableOption "Enable Noctalia desktop environment";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };
  };
}
