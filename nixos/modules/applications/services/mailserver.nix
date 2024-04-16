{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.mailserver;
in {
  imports = [inputs.simple-nixos-mailserver.nixosModule];

  options = {
    custom.applications.services.mailserver = {
      enable = lib.mkEnableOption "Enable mail server suite";

      baseDomain = lib.mkOption {
        type = lib.types.str;
        description = "The base domain of the mail server";
      };

      accounts = {
        primary = {
          passwordFile = lib.mkOption {
            type = lib.types.path;
            description = "The path of the password file for this user";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    mailserver = {
      enable = true;
      fqdn = "mail.${cfg.baseDomain}";
      domains = ["${cfg.baseDomain}"];

      # A list of all login accounts. To create the password hashes, use
      # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
      loginAccounts = {
        "mail@${cfg.baseDomain}" = {
          hashedPasswordFile = cfg.accounts.primary.passwordFile;
          aliases = ["@${cfg.baseDomain}"];
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

      certificateDomains = ["smtp.${cfg.baseDomain}" "imap.${cfg.baseDomain}"];

      certificateScheme = "acme-nginx";
    };
  };
}
