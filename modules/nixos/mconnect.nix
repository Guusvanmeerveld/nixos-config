{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.mconnect;
in {
  options = {
    programs.mconnect = {
      enable = lib.mkEnableOption "Enable MConnect";

      package = lib.mkPackageOption pkgs "mconnect" {};

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        description = "Enable default firewall ports for basic functionality";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    networking.firewall = {
      allowedUDPPorts = lib.optional cfg.openFirewall 51820;
      allowedTCPPortRanges = [
        {
          from = 9970;
          to = 9975;
        }
      ];
    };
  };
}
