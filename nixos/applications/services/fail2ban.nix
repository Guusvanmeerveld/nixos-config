{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.fail2ban;
in {
  options = {
    custom.applications.services.fail2ban = {
        enable = lib.mkEnableOption "Enable Fail2ban intrusion prevention software";
    };
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;

      bantime = "24h";
    };
  };
}
