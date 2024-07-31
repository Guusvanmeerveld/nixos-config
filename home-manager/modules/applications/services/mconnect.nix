{
  lib,
  config,
  outputs,
  ...
}: let
  cfg = config.custom.applications.services.mconnect;
in {
  imports = [outputs.homeManagerModules.mconnect];

  options = {
    custom.applications.services.mconnect = {
      enable = lib.mkEnableOption "Enable MConnect";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mconnect = {
      enable = true;
    };
  };
}
