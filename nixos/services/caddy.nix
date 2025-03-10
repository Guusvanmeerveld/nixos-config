{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.caddy;
in {
  options = {
    custom.services.caddy = {
      enable = lib.mkEnableOption "Enable Caddy web server";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
    };

    networking.firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}
