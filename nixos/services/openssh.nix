{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.openssh;
in {
  options = {
    custom.services.openssh = {
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

      inherit (cfg) openFirewall;

      settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = false;
      };
    };
  };
}
