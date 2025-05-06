{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.sudo-rs;
in {
  options = {
    custom.programs.sudo-rs = {
      enable = lib.mkEnableOption "Enable sudo-rs, a secure sudo replacement";
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo-rs = {
      enable = true;

      execWheelOnly = true;
      wheelNeedsPassword = false;
    };
  };
}
