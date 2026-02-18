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
      services = {
        recyclarr = {
          enable = true;

          configuration = {
            radarr = {
              radarr-main = {
                api_key = {
                  _secret = cfg.radarr.keyPath;
                };

                base_url = "http://localhost:${toString config.services.radarr.settings.server.port}";

                delete_old_custom_formats = true;
                replace_existing_custom_formats = true;

                media_naming = {
                  folder = "jellyfin-imdb";

                  movie = {
                    rename = "true";
                    standard = "jellyfin-imdb";
                  };
                };

                include = [
                  # Quality sizes (only needed once)
                  {template = "radarr-quality-definition-movie";}

                  # HD Bluray + WEB (1080p)
                  {template = "radarr-quality-profile-hd-bluray-web";}
                  {template = "radarr-custom-formats-hd-bluray-web";}

                  # UHD Bluray + WEB (4K)
                  {template = "radarr-quality-profile-uhd-bluray-web";}
                  {template = "radarr-custom-formats-uhd-bluray-web";}

                  # Remux-1080p - Anime
                  {template = "radarr-quality-profile-anime";}
                  {template = "radarr-custom-formats-anime";}
                ];

                # https://trash-guides.info/Radarr/Radarr-collection-of-custom-formats/
                custom_formats = [
                  # Set format score of HEVC content to -5
                  {
                    assign_scores_to = [
                      {
                        name = "HD Bluray + WEB";
                        score = -5;
                      }
                      {
                        name = "Remux-1080p - Anime";
                        score = -5;
                      }
                    ];

                    trash_ids = [
                      "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
                    ];
                  }
                ];
              };
            };

            sonarr = {
              sonarr-main = {
                api_key = {
                  _secret = cfg.sonarr.keyPath;
                };

                base_url = "http://localhost:${toString config.services.sonarr.settings.server.port}";

                delete_old_custom_formats = true;
                replace_existing_custom_formats = true;

                media_naming = {
                  series = "jellyfin-tvdb";
                  season = "default";

                  episodes = {
                    rename = true;

                    standard = "default";
                    daily = "default";
                    anime = "default";
                  };
                };

                include = [
                  {template = "sonarr-quality-definition-series";}

                  # WEB-1080P
                  {template = "sonarr-v4-quality-profile-web-1080p";}
                  {template = "sonarr-v4-custom-formats-web-1080p";}

                  # Remux 1080p - Anime
                  {template = "sonarr-v4-quality-profile-anime";}
                  {template = "sonarr-v4-custom-formats-anime";}
                ];

                # https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats
                custom_formats = [
                  # Set format score of non original language content to -10000 to avoid downloading
                  {
                    assign_scores_to = [
                      {
                        name = "WEB-1080p";
                        score = -10000;
                      }
                      {
                        name = "Remux-1080p - Anime";
                        score = -10000;
                      }
                    ];

                    trash_ids = [
                      # Unwanted
                      "ae575f95ab639ba5d15f663bf019e3e8" # Original language only
                    ];
                  }

                  # Set format score of HEVC content to -5
                  {
                    assign_scores_to = [
                      {
                        name = "WEB-1080p";
                        score = -5;
                      }
                      {
                        name = "Remux-1080p - Anime";
                        score = -5;
                      }
                    ];

                    trash_ids = [
                      "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
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
