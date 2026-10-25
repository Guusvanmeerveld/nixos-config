{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.librewolf;

  theme-package = cfg.theme;
  theme-path = "${theme-package}/share/firefox";
in {
  options.custom.programs.librewolf = {
    enable = lib.mkEnableOption "Enable Librewolf browser";

    theme = lib.mkPackageOption pkgs.custom.firefox.themes "blur" {};
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit (config.programs.librewolf) package;
        appId = "librewolf";
        keybind = "$mod+c";
        workspace = 3;
      }
    ];

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = 1;
    };

    programs.librewolf = let
      settings = {
        "browser.startup.homepage" = "about:home";

        # Bookmarks
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.bookmarks.addedImportButton" = false;
        "browser.tabs.loadBookmarksInTabs" = true;

        # QoL
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.tabs.warnOnClose" = false;
        "browser.tabs.warnOnQuit" = false;
        "browser.translations.automaticallyPopup" = false;

        # Enable search suggestions
        "browser.search.suggest.enabled" = true;

        # Disable restore session
        "browser.sessionstore.resume_from_crash" = false;
        "browser.startup.couldRestoreSession.count" = 2;

        "browser.download.useDownloadDir" = true;

        # Disable the browser asking whether to enable installed extensions.
        "extensions.autoDisableScopes" = 0;

        "middlemouse.paste" = false;
        "general.smoothScroll" = true;

        # Open PDF's in browser.
        "browser.download.open_pdf_attachments_inline" = true;
        # PDF viewer zoom page-fit
        "pdfjs.defaultZoomValue" = "page-fit";

        "browser.tabs.loadInBackground" = false;

        # Enable https first
        "dom.security.https_first" = true;
        "dom.security.https_only_mode" = false;

        # Open devtools on the right
        "devtools.toolbox.host" = "right";
        # Configure devtools font size
        "devtools.toolbox.zoomValue" = 1.3;
        # Disable devtools simple highlight message
        "devtools.inspector.simple-highlighters.message-dismissed" = true;

        # Extension for webgl privacy is installed.
        "webgl.disabled" = false;

        "media.ffmpeg.vaapi.enabled" = true;

        # Privacy
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.clearOnShutdown_v2.cache" = true;

        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.clearOnShutdown.siteSettings" = true;
        "network.cookie.lifetimePolicy" = 1;

        "privacy.resistFingerprinting" = false;

        # UI
        "ui.prefersReducedMotion" = 1;
        "toolkit.cosmeticAnimations.enabled" = false;
        "browser.tabs.tabMinWidth" = 100;
        "browser.compactmode.show" = true;

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;

        # Performance
        "layers.acceleration.disabled" = false;

        # Theme
        "layout.css.prefers-color-scheme.content-override" = 0;
        "ui.systemUsesDarkTheme" = 1;

        # Media
        "media.block-autoplay-until-in-foreground" = true;
        "media.block-play-until-document-interaction" = true;
        "media.block-play-until-visible" = true;
        "media.autoplay.blocking_policy" = 2;
      };

      userChrome = ''
        @import "${theme-path}/userChrome.css";
      '';

      userContent = ''
        @import "${theme-path}/userContent.css";
      '';
    in {
      enable = true;

      globalExtensions = with pkgs.nur.repos.rycee.firefox-addons; [ublock-origin canvasblocker];

      profiles = {
        default = {
          inherit settings userChrome userContent;

          extensions = {
            force = true;

            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              bitwarden
              translate-web-pages
              clearurls
              darkreader
              buster-captcha-solver
              consent-o-matic
            ];
          };

          bookmarks = {
            force = true;

            settings = [
              {
                name = "Apps";
                toolbar = true;

                bookmarks = [
                  {
                    name = "Beszel";
                    url = "https://beszel.sun.guusvanmeerveld.dev";
                  }
                  {
                    name = "Jellyfin";
                    url = "https://jellyfin.sun.guusvanmeerveld.dev";
                  }
                  {
                    name = "Immich";
                    url = "https://immich.sun.guusvanmeerveld.dev";
                  }
                  {
                    name = "Dawarich";
                    url = "https://dawarich.sun.guusvanmeerveld.dev";
                  }
                  {
                    name = "Sonarr";
                    url = "https://sonarr.sun.guusvanmeerveld.dev";
                  }
                  {
                    name = "Radarr";
                    url = "https://radarr.sun.guusvanmeerveld.dev";
                  }
                  {
                    name = "qBittorrent";
                    url = "https://qbittorrent.sun.guusvanmeerveld.dev";
                  }
                  {
                    name = "Syncthing";
                    url = "http://localhost:8384/";
                  }
                  {
                    name = "DuckDuckGo AI";
                    url = "https://duck.ai";
                  }
                ];
              }
            ];
          };

          search = {
            force = true;

            default = "degoog";
            engines = with lib;
              mkMerge [
                {
                  nix-packages = {
                    name = "Nix Packages";
                    urls = [
                      {
                        template = "https://search.nixos.org/packages";
                        params = [
                          {
                            name = "type";
                            value = "packages";
                          }
                          {
                            name = "query";
                            value = "{searchTerms}";
                          }
                        ];
                      }
                    ];

                    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    definedAliases = ["@np"];
                  };

                  degoog = {
                    name = "Degoog";
                    urls = [
                      {
                        template = "https://degoog.sun.guusvanmeerveld.dev/search";
                        params = [
                          {
                            name = "q";
                            value = "{searchTerms}";
                          }
                        ];
                      }
                    ];

                    # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    definedAliases = ["@deg"];
                  };

                  mynixos = {
                    name = "MyNixOS";
                    urls = [
                      {
                        template = "https://mynixos.com/search";
                        params = [
                          {
                            name = "q";
                            value = "{searchTerms}";
                          }
                        ];
                      }
                    ];

                    iconMapObj."16" = "https://mynixos.com/favicon.ico";
                    definedAliases = ["@mn"];
                  };

                  noogle = {
                    name = "Noogle";
                    urls = [
                      {
                        template = "https://noogle.dev/q";
                        params = [
                          {
                            name = "term";
                            value = "{searchTerms}";
                          }
                        ];
                      }
                    ];

                    iconMapObj."16" = "https://noogle.dev/favicon.ico";
                    definedAliases = ["@no"];
                  };

                  nixos-wiki = {
                    name = "NixOS Wiki";
                    urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
                    iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
                    definedAliases = ["@nw"];
                  };
                }
                (listToAttrs (map (engine: {
                    name = engine;
                    value = {
                      metaData.hidden = true;
                    };
                  }) [
                    "bing"
                    "google"
                    "wikipedia"
                    "policy-StartPage"
                    "policy-Mojeek"
                    "policy-MetaGer"
                    "policy-SearXNG - searx.be"
                    "policy-DuckDuckGo Lite"
                    "7esoorv3@alefvanoon.anonaddy.medefault"
                  ]))
              ];
          };
        };

        clipit = {
          inherit settings userChrome userContent;

          id = 1;

          bookmarks = {
            force = true;

            settings = [
              {
                name = "TMS";
                toolbar = true;

                bookmarks = [
                  {
                    name = "Home";
                    url = "https://tms.clipit.nl/tms/clipit/home.aspx";
                  }
                  {
                    name = "Search";
                    url = "https://tms.clipit.nl/tms/reportdefinition.aspx?report=clipit-searchnewssourcelink";
                  }
                  {
                    name = "Grabber Log Tickets";
                    url = "https://tms.clipit.nl/tms/clipit/grabberlogticketlist.aspx";
                  }
                  {
                    name = "Missed messages";
                    url = "https://tms.clipit.nl/tms/clipit/newssource.aspx?id=778271";
                  }
                  {
                    name = "New newssource";
                    url = "https://tms.clipit.nl/tms/clipit/newssource.aspx?newssourcetype=1";
                  }
                  {
                    name = "Newsource ID lookup";
                    url = "javascript:var%20n%20=%20window.prompt(%22Newssource%20ID%22,%22%22);if(n){document.location.href=%22http://tms.clipit.nl/tms/clipit/newssource.aspx?id=%22+n.replace(%27.%27,%27%27);}";
                  }
                ];
              }
              "separator"
              {
                name = "Tools";
                toolbar = true;

                bookmarks = [
                  {
                    name = "Wiki";
                    url = "https://sites.google.com/a/clipit.nl/wiki/home";
                  }
                  {
                    name = "Workhours sheet";
                    url = "https://docs.google.com/spreadsheets/d/14yVhMNHRE3vFTMoUOPPULK9S4q4uLMXox_C3-dYEUJo/edit";
                  }
                  {
                    name = "MCP Issues";
                    url = "https://docs.google.com/spreadsheets/d/1Lg97sp7OzyUxNC4ZnohPAMnGaBEhYCvhnIwoe6L6mNc/edit";
                  }
                  {
                    name = "DEV vacations";
                    url = "https://docs.google.com/spreadsheets/d/1sTW2HHNiqN5OTvxb9V7uVfPuwGdh4OIvPDaFRbWTg5s/edit";
                  }
                  {
                    name = "XPath cheatsheet";
                    url = "https://devhints.io/xpath";
                  }
                  {
                    name = "RSS Lookup for current site";
                    url = "javascript:(function(){var currentUrl=window.location.href; var encodedUrl=encodeURIComponent(currentUrl); var targetUrl='https://www.rsslookup.com/?url='+encodedUrl; window.open(targetUrl,'_blank','noreferrer');})();";
                  }
                ];
              }
            ];
          };
        };
      };
    };
  };
}
