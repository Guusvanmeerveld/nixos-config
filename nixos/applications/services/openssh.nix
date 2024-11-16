{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.openssh;
in {
  options = {
    custom.applications.services.openssh = {
        enable = lib.mkEnableOption "Enable OpenSSH server";

        openFirewall = lib.mkOption {
            type = lib.types.bool;
            default = config.networking.firewall.enable;
            description = "Open firewall ports";
        };
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
        enable = true;

        openFirewall = cfg.openFirewall;

        settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
        };
    };
  };
}
