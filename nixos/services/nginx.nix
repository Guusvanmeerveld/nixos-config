{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.nginx;
in {
  options = {
    custom.services.nginx = {
      enable = lib.mkEnableOption "Enable NGINX web server";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
    };

    networking.firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}
