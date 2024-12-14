{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.firefox;

  theme-package = cfg.theme;
  theme-path = "${theme-package}/share/firefox";
in {
  options = {
    custom.applications.graphical.firefox = {
      enable = lib.mkEnableOption "Enable Firefox browser";

      theme = lib.mkPackageOption pkgs.custom.firefox.themes "blur" {};
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };

    programs.firefox = {
      enable = true;

      # Remove unneeded components
      policies = {
        DisableTelemetry = true;
        DisablePocket = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DontCheckDefaultBrowser = true;
        CaptivePortal = true;
        DisableAppUpdate = true;
        OfferToSaveLogins = false;
      };

      profiles = {
        default = {
          isDefault = true;

          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
            translate-web-pages
            libredirect
            clearurls
            darkreader
            canvasblocker
            buster-captcha-solver

            react-devtools
          ];

          bookmarks = [
            {
              name = "Wikipedia";
              tags = ["wiki"];
              keyword = "wiki";
              url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&amp;go=Go";
            }
            {
              name = "Git";
              tags = ["git"];
              keyword = "git";
              url = "https://git.guusvanmeerveld.dev/explore/repos?sort=recentupdate&language=&q=%s";
            }
            {
              name = "Github";
              tags = ["git"];
              keyword = "github";
              url = "https://github.com/search?q=%s&type=repositories";
            }
            {
              name = "MaterialTube";
              tags = ["youtube"];
              keyword = "yt";
              url = "https://materialtube.guusvanmeerveld.dev/results?search_query=%s";
            }
          ];

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

          containersForce = true;

          userChrome = ''
            @import "${theme-path}/userChrome.css";
          '';
          userContent = ''
            @import "${theme-path}/userContent.css";
          '';

          search = {
            force = true;
            default = "SearX";
            order = ["SearX"];

            engines = {
              "SearX" = {
                urls = [
                  {
                    template = "https://search.guusvanmeerveld.dev/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                definedAliases = ["@sx"];
              };
            };
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

            "browser.search.suggest.enabled" = true;
            "browser.translations.enable" = false;
            "browser.formfill.enable" = false;
            "browser.formautofill.enabled" = false;
            "browser.urlbar.autoFill" = false;
            "browser.vpn_promo.enabled" = false;
            "identity.fxaccounts.enabled" = false;

            "browser.download.useDownloadDir" = true;

            "middlemouse.paste" = false;
            "general.smoothScroll" = true;

            "browser.download.open_pdf_attachments_inline" = true;

            "browser.tabs.loadInBackground" = false;

            "devtools.inspector.enabled" = true;

            # Security
            "dom.security.https_only_mode" = true;
            "rowser.xul.error_pages.expert_bad_cert" = true;
            "security.insecure_password.ui.enabled" = true;
            "security.ssl.require_safe_negotiation" = true;
            "security.pki.crlite_mode" = 2;

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

            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.ping-centre.telemetry" = false;
            "datareporting.healthreport.service.enabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "datareporting.sessions.current.clean" = true;
            "devtools.onboarding.telemetry.logged" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.prompted" = 2;
            "toolkit.telemetry.rejected" = true;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.server" = "";
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.unifiedIsOptIn" = false;
            "toolkit.telemetry.updatePing.enabled" = false;

            # UI
            "ui.prefersReducedMotion" = 1;
            "toolkit.cosmeticAnimations.enabled" = false;
            "browser.tabs.tabMinWidth" = 100;
            "browser.compactmode.show" = true;

            "browser.display.use_document_fonts" = 0;

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
