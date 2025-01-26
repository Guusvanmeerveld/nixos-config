{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.kdeconnect;
in {
  options = {
    custom.services.kdeconnect = {
      openFirewall = lib.mkEnableOption "Open needed ports in firewall";
    };
  };

  config = {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };
}
