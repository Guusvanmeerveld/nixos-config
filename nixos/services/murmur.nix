{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.murmur;
in {
  options = {
    custom.services.murmur = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Murmur service";

      caddy.hostname = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf;

    caddyCertDir = "${config.services.caddy.dataDir}/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
  in
    mkIf cfg.enable {
      custom.services.restic.client.backups.murmur = {
        services = ["murmur"];

        files = [
          config.services.murmur.stateDir
        ];
      };

      systemd.tmpfiles.rules = [
        "C+ ${config.services.murmur.stateDir}/certificates 0700 murmur murmur - ${caddyCertDir}/${cfg.caddy.hostname}"
      ];

      services = {
        caddy = mkIf (cfg.caddy.hostname != null) {
          virtualHosts = {
            "https://${cfg.caddy.hostname}" = {
              extraConfig = ''
                respond "Murmur"
              '';
            };
          };
        };

        murmur = {
          enable = true;

          registerHostname = cfg.caddy.hostname;
          registerName = "Guus's Mumble server";

          clientCertRequired = true;

          environmentFile = "/secrets/murmur.env";

          password = "$MURMURD_PASSWORD";

          sslCert = "${config.services.murmur.stateDir}/certificates/${cfg.caddy.hostname}.crt";
          sslKey = "${config.services.murmur.stateDir}/certificates/${cfg.caddy.hostname}.key";

          extraConfig = ''
            obfuscate=true
          '';

          openFirewall = true;
        };
      };
    };
}
