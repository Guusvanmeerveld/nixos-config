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
    };
  };

  config = let
    inherit (lib) mkIf mapAttrs' nameValuePair optionals;

    fqdn = "mail.${cfg.mailDomain}";
    caddyCertDir = "${config.services.caddy.dataDir}/.local/share/caddy/certificates/local/acme";
  in
    mkIf cfg.enable {
      services.caddy = {
        "https://${fqdn}" = {
          extraConfig = ''
            respond "Mail server is working!"
          '';
        };
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
            catchAll = optionals userOptions.catchAll [cfg.domain];
          })
        cfg.users;

        enableImap = false;
        enableImapSsl = true;

        enableManageSieve = true;

        enableSubmission = true;
        enableSubmissionSsl = true;

        certificateScheme = "acme";
        certificateFile = "${caddyCertDir}/${fqdn}/${fqdn}.crt";
      };
    };
}
