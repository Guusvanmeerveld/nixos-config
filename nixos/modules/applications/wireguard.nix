{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.wireguard;
in {
  options = {
    custom.applications.wireguard = {
      enable = lib.mkEnableOption "Enable wireguard client";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedUDPPorts = [51820];
    };
  };
}
