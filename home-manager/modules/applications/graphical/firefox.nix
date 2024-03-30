{ lib, config, pkgs, inputs, ... }:
let cfg = config.custom.applications.graphical.firefox; in
{
  imports = [ inputs.nur.nixosModules.nur ];

  options = {
    custom.applications.graphical.firefox = {
      enable = lib.mkEnableOption "Enable Firefox browser";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      # Remove unneeded components
      policies = {
        DisableTelemetry = true;
        DisablePocket = true;
        DisableFirefoxStudies = true;
        DisableFirefoxScreenshots = true;
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

          extensions = with config.nur.repos.rycee.firefox-addons;
            [
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
              tags = [ "wiki" ];
              keyword = "wiki";
              url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&amp;go=Go";
            }
            {
              name = "Git";
              tags = [ "git" ];
              keyword = "git";
              url = "https://git.guusvanmeerveld.dev/explore/repos?sort=recentupdate&language=&q=%s";
            }
            {
              name = "Github";
              tags = [ "git" ];
              keyword = "github";
              url = "https://github.com/search?q=%s&type=repositories";
            }
            {
              name = "MaterialTube";
              tags = [ "youtube" ];
              keyword = "yt";
              url = "https://materialtube.guusvanmeerveld.dev/results?search_query=%s";
            }
          ];

          # containers = {
          #   Development = {
          #     color = "red";
          #     icon = "briefcase";
          #     id = 1;
          #   };

          #   Relax = {
          #     color = "blue";
          #     icon = "chill";
          #     id = 2;
          #   };
          # };

          search = {
            force = true;
            default = "DuckDuckGo";
            order = [ "DuckDuckGo" ];

            engines = {
              "DuckDuckGo" = {
                urls = [{
                  template = "https://duckduckgo.com/";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];

                definedAliases = [ "@ddg" ];
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

            "browser.search.suggest.enabled" = false;
            "browser.translations.enable" = false;
            "browser.formfill.enable" = false;
            "browser.formautofill.enabled" = false;
            "browser.urlbar.autoFill" = false;
            "browser.vpn_promo.enabled" = false;
            "identity.fxaccounts.enabled" = false;

            "browser.download.useDownloadDir" = true;

            "middlemouse.paste" = false;

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

            # Privacy
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.downloads" = false;
            "privacy.globalprivacycontrol.enabled" = true;
            "privacy.donottrackheader.enabled" = true;

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
