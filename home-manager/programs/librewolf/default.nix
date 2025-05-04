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
  options = {
    custom.programs.librewolf = {
      enable = lib.mkEnableOption "Enable Librewolf browser";

      theme = lib.mkPackageOption pkgs.custom.firefox.themes "blur" {};
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway.config = {
      assigns."3" = [
        {
          app_id = "^librewolf$";
        }
      ];

      keybindings = {
        "${config.wayland.windowManager.sway.config.modifier}+c" =
          pkgs.custom.scripts.swayFocusOrStart "librewolf" (lib.getExe config.programs.librewolf.package);
      };
    };

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };

    programs.librewolf = {
      enable = true;

      profiles = {
        default = {
          isDefault = true;

          extensions = {
            force = true;

            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              ublock-origin
              bitwarden
              translate-web-pages
              libredirect
              clearurls
              darkreader
              canvasblocker
              buster-captcha-solver
              react-devtools
              consent-o-matic
            ];

            settings = {
              "uBlock0@raymondhill.net".settings = import ./extensions/ublock.nix {inherit lib;};
              "addon@darkreader.org".settings = import ./extensions/darkreader.nix;
            };
          };

          bookmarks = {
            force = true;

            settings = [
              {
                name = "Syncthing";
                url = "http://localhost:8384/";
              }
            ];
          };

          containersForce = true;
          containers = {
            Development = {
              color = "red";
              icon = "briefcase";
              id = 1;
            };

            Relax = {
              color = "blue";
              icon = "chill";
              id = 2;
            };
          };

          userChrome = ''
            @import "${theme-path}/userChrome.css";
          '';
          userContent = ''
            @import "${theme-path}/userContent.css";
          '';

          search = {
            force = true;

            default = "ddg";
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

          settings = {
            "browser.startup.homepage" = "about:home";

            # Bookmarks
            "browser.toolbars.bookmarks.visibility" = "never";
            "browser.bookmarks.addedImportButton" = false;

            # QoL
            "browser.tabs.closeWindowWithLastTab" = false;
            "browser.tabs.warnOnClose" = false;
            "browser.tabs.warnOnQuit" = false;

            # Enable search suggestions
            "browser.search.suggest.enabled" = true;

            "browser.download.useDownloadDir" = true;
            "extensions.autoDisableScopes" = 0;

            "middlemouse.paste" = false;
            "general.smoothScroll" = true;

            # Open PDF's in browser.
            "browser.download.open_pdf_attachments_inline" = true;

            "browser.tabs.loadInBackground" = false;

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

            # "browser.display.use_document_fonts" = 0;

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
        };
      };
    };
  };
}
