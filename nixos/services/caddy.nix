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

      openFirewall = lib.mkEnableOption "Open Caddy ports in firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;

      globalConfig = ''
        admin off
      '';
    };

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [80 443];
  };
}
