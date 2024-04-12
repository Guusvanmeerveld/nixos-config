{...}: {
  config = {
    services.vaultwarden = {
      enable = true;

      config = {
        DOMAIN = "https://bitwarden.guusvanmeerveld.dev";
        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;

        ROCKET_LOG = "critical";

        SMTP_PORT = 587;
        SMTP_SECURITY = "starttls";
        SMTP_SSL = false;

        SMTP_FROM = "vaultwarden@guusvanmeerveld.dev";
        SMTP_FROM_NAME = "Guus' Vaultwarden server";
      };

      backupDir = "/var/backup/vaultwarden";
      environmentFile = "/var/lib/vaultwarden.env";
    };
  };
}
