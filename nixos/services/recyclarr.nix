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

                  # # Remux + WEB 1080p
                  # {template = "radarr-quality-profile-remux-web-1080p";}
                  # {template = "radarr-custom-formats-remux-web-1080p";}

                  # # Remux + WEB 2160p
                  # {template = "radarr-quality-profile-remux-web-2160p";}
                  # {template = "radarr-custom-formats-remux-web-2160p";}
                ];

                custom_formats = [
                  {
                    assign_scores_to = [{name = "HD Bluray + WEB";}];
                    trash_ids = [
                      # HQ Release Groups
                      "ed27ebfef2f323e964fb1f61391bcb35" # HD Bluray Tier 01
                      "c20c8647f2746a1f4c4262b0fbbeeeae" # HD Bluray Tier 02
                      "5608c71bcebba0a5e666223bae8c9227" # HD Bluray Tier 03
                      "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
                      "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
                      "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03
                      # Misc
                      "e7718d7a3ce595f289bfee26adc178f5" # Repack/Proper
                      "ae43b294509409a6a13919dedd4764c4" # Repack2
                      "5caaaa1c08c1742aa4342d8c4cc463f2" # Repack3
                      # Unwanted
                      "ed38b889b31be83fda192888e2286d83" # BR-DISK
                      "e6886871085226c3da1830830146846c" # Generated Dynamic HDR
                      "90a6f9a284dff5103f6346090e6280c8" # LQ
                      "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
                      "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
                      "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
                      "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
                      "0a3f082873eb454bde444150b70253cc" # Extras
                      "712d74cd88bceb883ee32f773656b1f5" # Sing-Along Versions
                      "cae4ca30163749b891686f95532519bd" # AV1
                      # Streaming Services
                      "cc5e51a9e85a6296ceefe097a77f12f4" # BCORE
                      "16622a6911d1ab5d5b8b713d5b0036d4" # CRiT
                      "2a6039655313bf5dab1e43523b62c374" # MA
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

                  # Anime
                  {template = "sonarr-v4-quality-profile-anime";}
                  {template = "sonarr-v4-custom-formats-anime";}
                ];

                custom_formats = [
                  {
                    assign_scores_to = [{name = "WEB-1080p";}];
                    trash_ids = [
                      # Unwanted
                      "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
                      "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                      "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                      "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
                      "ae575f95ab639ba5d15f663bf019e3e8" # Original language only
                      "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
                      "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
                      # Misc
                      "ec8fa7296b64e8cd390a1600981f3923" # Repack/Proper
                      "eb3d5cc0a2be0db205fb823640db6a3c" # Repack v2
                      "44e7c4de10ae50265753082e5dc76047" # Repack v3
                      # Streaming Services
                      "d660701077794679fd59e8bdf4ce3a29" # AMZN
                      "f67c9ca88f463a48346062e8ad07713f" # ATVP
                      "77a7b25585c18af08f60b1547bb9b4fb" # CC
                      "36b72f59f4ea20aad9316f475f2d9fbb" # DCU
                      "dc5f2bb0e0262155b5fedd0f6c5d2b55" # DSCP
                      "89358767a60cc28783cdc3d0be9388a4" # DSNP
                      "7a235133c87f7da4c8cccceca7e3c7a6" # HBO
                      "a880d6abc21e7c16884f3ae393f84179" # HMAX
                      "f6cce30f1733d5c8194222a7507909bb" # Hulu
                      "0ac24a2a68a9700bcb7eeca8e5cd644c" # iT
                      "81d1fbf600e2540cee87f3a23f9d3c1c" # MAX
                      "d34870697c9db575f17700212167be23" # NF
                      "1656adc6d7bb2c8cca6acfb6592db421" # PCOK
                      "c67a75ae4a1715f2bb4d492755ba4195" # PMTP
                      "ae58039e1319178e6be73caab5c42166" # SHO
                      "1efe8da11bfd74fbbcd4d8117ddb9213" # STAN
                      "9623c5c9cac8e939c1b9aedd32f640bf" # SYFY
                      "218e93e5702f44a68ad9e3c6ba87d2f0" # HD Streaming Boost
                      # HQ Source Groups
                      "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
                      "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                      "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
                      "d0c516558625b04b363fa6c5c2c7cfd4" # WEB Scene
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
