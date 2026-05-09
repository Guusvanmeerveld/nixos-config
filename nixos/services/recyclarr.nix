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

                quality_profiles = [
                  {
                    trash_id = "d1d67249d3890e49bc12e275d989a7e9"; # HD Bluray + WEB
                    reset_unmatched_scores.enabled = true;
                  }
                  {
                    trash_id = "64fb5f9858489bdac2af690e27c8f42f"; # UHD Bluray + WEB
                    reset_unmatched_scores.enabled = true;
                  }
                  {
                    trash_id = "722b624f9af1e492284c4bc842153a38"; # [Anime] Remux-1080p
                    reset_unmatched_scores.enabled = true;
                  }
                ];

                # https://trash-guides.info/Radarr/Radarr-collection-of-custom-formats/
                custom_formats = [
                  # Set format score of HEVC content to -5
                  {
                    assign_scores_to = [
                      {
                        trash_id = "d1d67249d3890e49bc12e275d989a7e9";
                        score = -5;
                      }
                      {
                        trash_id = "722b624f9af1e492284c4bc842153a38";
                        score = -5;
                      }
                    ];

                    trash_ids = [
                      "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
                    ];
                  }
                  # Boost HDR10 plus because I don't have DV support
                  {
                    assign_scores_to = [
                      {
                        trash_id = "64fb5f9858489bdac2af690e27c8f42f";
                        score = 100;
                      }
                    ];

                    trash_ids = [
                      "caa37d0df9c348912df1fb1d88f9273a" # HDR10Plus Boost
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

                quality_profiles = [
                  {
                    trash_id = "72dae194fc92bf828f32cde7744e51a1"; # WEB-1080p
                    reset_unmatched_scores.enabled = true;
                  }
                  {
                    trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # [Anime] Remux-1080p
                    reset_unmatched_scores.enabled = true;
                  }
                ];

                # https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats
                custom_formats = [
                  # Set format score of non original language content to -10000 to avoid downloading
                  {
                    assign_scores_to = [
                      {
                        trash_id = "72dae194fc92bf828f32cde7744e51a1";
                        score = -10000;
                      }
                      {
                        trash_id = "20e0fc959f1f1704bed501f23bdae76f";
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
                        trash_id = "72dae194fc92bf828f32cde7744e51a1";
                        score = -5;
                      }
                      {
                        trash_id = "20e0fc959f1f1704bed501f23bdae76f";
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
