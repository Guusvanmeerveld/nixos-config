{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.virtualisation.docker;
in {
  options = {
    custom.virtualisation.docker = {
      enable = lib.mkEnableOption "Enable Docker";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;

      autoPrune = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [ctop];

    custom.usersGlobalGroups = ["docker"];
  };
}
