{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [inputs.simple-nixos-mailserver.nixosModule ./secrets.nix];

  mailserver = {
    enable = true;
    fqdn = "mail.guusvanmeerveld.dev";
    domains = ["guusvanmeerveld.dev"];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "mail@guusvanmeerveld.dev" = {
        hashedPasswordFile = config.age.secrets.email-password.path;
        aliases = ["@guusvanmeerveld.dev"];
      };
    };

    enableManageSieve = true;

    backup = {
      enable = true;

      cronIntervals = {
        daily = "30  3  *  *  *";
      };

      retain.daily = 7;

      # Backup to Syncthing directory
      snapshotRoot = lib.concatStringsSep "/" [config.services.syncthing.dataDir "mail-server-backup"];
    };

    certificateDomains = ["smtp.guusvanmeerveld.dev" "imap.guusvanmeerveld.dev"];

    certificateScheme = "acme-nginx";
  };

  services.radicale = {
    enable = true;
    settings = {
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale-htpasswd.path;
        htpasswd_encryption = "bcrypt";
      };

      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
  };
}
