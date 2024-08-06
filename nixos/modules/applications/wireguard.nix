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

      kernelModules.enable = lib.mkEnableOption "Enable wireguard kernel modules";
    };
  };

  config = {
    networking.firewall = {
      allowedUDPPorts = lib.optional cfg.openFirewall 51820;
    };

    networking.firewall.checkReversePath = cfg.openFirewall;

    boot.kernelModules = lib.optional cfg.kernelModules.enable "wireguard";
  };
}
