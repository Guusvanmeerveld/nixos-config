{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.sunshine;
in {
  options = {
    custom.services.sunshine = {
      enable = lib.mkEnableOption "Enable sunshine game streaming host";

      openFirewall = lib.mkEnableOption "Open required ports on firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      openFirewall = cfg.openFirewall;
      capSysAdmin = true;
    };
  };
}
