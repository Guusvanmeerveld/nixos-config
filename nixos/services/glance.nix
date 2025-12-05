{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.glance;
in {
  options = {
    custom.services.glance = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Glance web dashboard";

      port = mkOption {
        type = types.ints.u16;
        default = 8111;
        description = "The port to run the service on";
      };

      caddy.url = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.port}
              '';
            };
          };
        };

        glance = {
          enable = true;

          settings = {
            pages = [
              {
                name = "Home";
                columns = [
                  {
                    size = "small";
                    widgets = [
                      {
                        type = "clock";
                        hour-format = "24h";
                        timezone = [
                          {
                            timezone = "America/New_York";
                            label = "New York";
                          }
                          {
                            timezone = "Australia/Sydney";
                            label = "Sydney";
                          }
                        ];
                      }
                      {
                        type = "bookmarks";
                        groups = [
                          {
                            title = "";
                            links = [
                              {
                                title = "";
                              }
                            ];
                          }
                        ];
                      }
                      {
                        type = "server-stats";
                      }
                    ];
                  }
                  {
                    size = "full";
                    widgets = [
                      {
                        type = "search";
                        search-engine = "duckduckgo";
                        autofocus = true;
                      }
                      {
                        type = "monitor";
                        cache = "1m";
                        title = "Services";
                        sites = let
                          sunflowerDomain = "sun.guusvanmeerveld.dev";
                        in [
                          {
                            title = "Jellyfin";
                            url = "https://jellyfin.${sunflowerDomain}";
                            icon = "/assets/jellyfin-logo.png";
                          }
                          {
                            title = "Forgejo";
                            url = "https://forgejo.${sunflowerDomain}";
                            icon = "/assets/gitea-logo.png";
                          }
                          {
                            title = "Immich";
                            url = "https://immich.${sunflowerDomain}";
                            icon = "/assets/immich-logo.png";
                          }
                          {
                            title = "Miniflux";
                            url = "https://miniflux.${sunflowerDomain}";
                            icon = "/assets/adguard-logo.png";
                          }
                          {
                            title = "Homeassistant";
                            url = "https://homeassistant.${sunflowerDomain}";
                            icon = "/assets/adguard-logo.png";
                          }
                          {
                            title = "Ntfy";
                            url = "https://ntfy.${sunflowerDomain}";
                            icon = "/assets/adguard-logo.png";
                          }
                          {
                            title = "Vaultwarden";
                            url = "https://bitwarden.${sunflowerDomain}";
                            icon = "/assets/vaultwarden-logo.png";
                          }
                          {
                            title = "Mealie";
                            url = "https://mealie.${sunflowerDomain}";
                            icon = "/assets/vaultwarden-logo.png";
                          }
                        ];
                      }
                      {
                        type = "hacker-news";
                      }
                      {
                        type = "videos";
                        channels = [
                          "UCXuqSBlHAE6Xw-yeJA0Tunw" # Linus Tech Tips
                          "UCR-DXc1voovS8nhAvccRZhg" # Jeff Geerling
                          "UCsBjURrPoezykLs9EqgamOA" # Fireship
                          "UCBJycsmduvYEL83R_U4JriQ" # Marques Brownlee
                          "UCHnyfMqiRRG1u-2MsSQLbXA" # Veritasium
                        ];
                      }
                    ];
                  }
                  {
                    size = "small";
                    widgets = [
                      {
                        type = "weather";
                        location = "Wageningen";
                        units = "metric";
                        hour-format = "24h";
                      }
                      {
                        type = "releases";
                        cache = "1d";
                        repositories = [
                          "glanceapp/glance"
                          "home-assistant/core"
                          "dani-garcia/vaultwarden"
                          "immich-app/immich"
                          "syncthing/syncthing"
                          "jellyfin/jellyfin"
                        ];
                      }
                    ];
                  }
                ];
              }
            ];

            server = {
              inherit (cfg) port;
            };
          };
        };
      };
    };
}
