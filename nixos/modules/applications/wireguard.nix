{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.wireguard;
in {
  options = {
    custom.applications.wireguard = {
      # enable = lib.mkEnableOption "Enable wireguard client";

      openFirewall = lib.mkEnableOption "Open default port";
    };
  };

  config = {
    networking.firewall = {
      allowedUDPPorts = lib.optional cfg.openFirewall 51820;
    };
  };
}
