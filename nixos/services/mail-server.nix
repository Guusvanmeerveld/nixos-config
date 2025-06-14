{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.mail-server;
in {
  imports = [inputs.simple-nixos-mailserver.nixosModules.default];

  options = {
    custom.services.mail-server = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Mail Server service";

      openFirewall = mkEnableOption "Open default ports";

      mailDomain = mkOption {
        type = types.str;
        description = "The main domain used to reach the mail server";
      };

      domainPrefix = mkOption {
        type = types.str;
        description = "The prefix for the mail domain";
        default = "mail";
      };

      users = mkOption {
        type = with types;
          attrsOf (submodule ({name, ...}: {
            options = {
              passwordFile = mkOption {
                type = str;
                default = "/secrets/mail-server/${name}/passwordFile";
                description = "Path to the password file for this user";
              };

              catchAll = mkEnableOption "Make this account a catch all address for this server";
            };
          }));

        default = {};
        description = "List of mail accounts";
      };

      smtpRelay = {
        enable = mkEnableOption "Enable SMTP relay";

        domain = mkOption {
          type = types.str;
        };

        port = mkOption {
          type = types.ints.u16;
          default = 587;
        };

        secretsFile = mkOption {
          type = types.path;
        };
      };
    };
  };

  config = let
    inherit (lib) mkIf mapAttrs' nameValuePair optionals;

    fqdn = "${cfg.domainPrefix}.${cfg.mailDomain}";
    caddyCertDir = "${config.services.caddy.dataDir}/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
  in
    mkIf cfg.enable {
      services = {
        caddy.virtualHosts = {
          "https://${fqdn}" = {
            extraConfig = ''
              respond "Mail server is working!"
            '';
          };
        };
      };

      services.postfix = mkIf cfg.smtpRelay.enable {
        mapFiles."sasl_passwd" = toString cfg.smtpRelay.secretsFile;

        relayHost = cfg.smtpRelay.domain;
        relayPort = cfg.smtpRelay.port;

        extraConfig = ''
          smtp_sasl_password_maps = hash:/var/lib/postfix/conf/sasl_passwd
          smtp_sasl_auth_enable = yes
          smtp_sasl_security_options = noanonymous
        '';
      };

      mailserver = {
        enable = true;
        stateVersion = 1;

        inherit (cfg) openFirewall;

        inherit fqdn;
        domains = [cfg.mailDomain];

        loginAccounts = mapAttrs' (username: userOptions:
          nameValuePair "${username}@${cfg.mailDomain}" {
            hashedPasswordFile = userOptions.passwordFile;
            catchAll = optionals userOptions.catchAll [cfg.mailDomain];
          })
        cfg.users;

        enableImap = false;
        enableImapSsl = true;

        enableManageSieve = true;

        enableSubmission = true;
        enableSubmissionSsl = true;

        virusScanning = true;

        dmarcReporting = {
          enable = true;

          domain = cfg.mailDomain;
          organizationName = "Nixos Mailserver";
        };

        certificateScheme = "manual";
        certificateFile = "${caddyCertDir}/${fqdn}/${fqdn}.crt";
        keyFile = "${caddyCertDir}/${fqdn}/${fqdn}.key";
      };
    };
}
