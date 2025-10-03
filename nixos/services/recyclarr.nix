{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.recyclarr;
in {
  options = {
    custom.services.recyclarr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Recyclarr, a command-line application that will automatically synchronize recommended settings from the TRaSH guides to your Sonarr/Radarr instances";

      radarr.keyPath = mkOption {
        type = types.path;
        description = "Path to the file containing the Radarr API key";
      };

      sonarr.keyPath = mkOption {
        type = types.path;
        description = "Path to the file containing the Sonarr API key";
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      systemd.services.recyclarr.serviceConfig.LoadCredential = [
        "radarr-api_key:${cfg.radarr.keyPath}"
        "sonarr-api_key:${cfg.sonarr.keyPath}"
      ];

      services = {
        recyclarr = {
          enable = true;

          configuration = {
            radarr = {
              radarr-main = {
                api_key = {
                  _secret = "/run/credentials/recyclarr.service/radarr-api_key";
                };

                base_url = "http://localhost:${toString config.services.radarr.settings.server.port}";

                quality_definition.type = "movie";

                custom_formats = [
                  {
                    trash_ids = [
                      # HQ Release Groups
                      "ed27ebfef2f323e964fb1f61391bcb35" # HD Bluray Tier 01
                      "c20c8647f2746a1f4c4262b0fbbeeeae" # HD Bluray Tier 02
                      "5608c71bcebba0a5e666223bae8c9227" # HD Bluray Tier 03
                      "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
                      "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
                      "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03
                    ];
                  }
                ];
              };
            };

            sonarr = {
              sonarr-main = {
                api_key = {
                  _secret = "/run/credentials/recyclarr.service/sonarr-api_key";
                };

                base_url = "http://localhost:${toString config.services.sonarr.settings.server.port}";

                quality_definition.type = "series";

                custom_formats = [
                  {
                    trash_ids = [
                      # Unwanted
                      "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
                      "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                      "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                      "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
                      "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
                    ];
                  }
                ];
              };
            };
          };
        };
      };
    };
}
