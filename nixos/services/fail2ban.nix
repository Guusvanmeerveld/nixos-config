{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.fail2ban;
in {
  options = {
    custom.services.fail2ban = {
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
