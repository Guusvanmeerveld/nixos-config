{ lib, config, ... }:
let
  cfg = config.custom.applications.docker;
in
{
  options = {
    custom.applications.docker = {
      enable = lib.mkEnableOption "Enable docker service";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
  };

}
