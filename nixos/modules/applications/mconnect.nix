{
  lib,
  config,
  outputs,
  ...
}: let
  cfg = config.custom.applications.mconnect;
in {
  imports = [outputs.nixosModules.mconnect];

  options = {
    custom.applications.mconnect = {
      enable = lib.mkEnableOption "Enable MConnect";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mconnect.enable = true;
  };
}
