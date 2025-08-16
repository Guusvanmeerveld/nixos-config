{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    types
    literalExpression
    mkIf
    getExe
    ;

  cfg = config.services.soularr;

  iniFormat = pkgs.formats.ini {};

  configFile = iniFormat.generate "soularr-settings" {
    "Lidarr" = {
      # Get from Lidarr: Settings > General > Security
      api_key = cfg.lidarr.apiKey;
      # URL Lidarr uses (e.g., what you use in your browser)
      host_url = "http://localhost:${toString config.services.lidarr.settings.server.port}";
      # Path to slskd downloads inside the Lidarr container
      download_dir = config.services.slskd.settings.directories.downloads;
      # If true, Lidarr won't auto-import from Slskd
      disable_sync = false;
    };

    "Slskd" = {
      # Create manually (see docs)
      api_key = config.services.slskd.settings.authentication.api_keys."soularr".key;
      # URL Slskd uses
      host_url = "http://${config.custom.services.soulseek.address}:${toString config.services.slskd.settings.web.port}";
      url_base = "/";
      # Download path inside Slskd container
      download_dir = config.services.slskd.settings.directories.downloads;
      # Delete search after Soularr runs
      delete_searches = false;
      # Max seconds to wait for downloads (prevents infinite hangs)
      stalled_timeout = "3600";
    };

    "Release Settings" = {
      # Pick release with most common track count
      use_most_common_tracknum = true;
      allow_multi_disc = true;
      # Accepted release countries
      accepted_countries = "Europe,Japan,United Kingdom,United States,[Worldwide],Australia,Canada";
      # Don't check the region of the release
      skip_region_check = false;
      # Accepted formats
      accepted_formats = "CD,Digital Media,Vinyl";
    };

    "Search Settings" = {
      search_timeout = 5000;
      maximum_peer_queue = 50;
      # Minimum upload speed (bits/sec)
      minimum_peer_upload_speed = 0;
      # Minimum match ratio between Lidarr track and Soulseek filename
      minimum_filename_match_ratio = 0.8;
      # Preferred file types and qualities (most to least preferred)
      # Use "flac" or "mp3" to ignore quality details
      allowed_filetypes = "flac 24/192,flac 16/44.1,flac,mp3 320,mp3";
      ignored_users = "";
      # Set to False to only search for album titles (Note Soularr does not search for individual tracks, this setting searches for track titles but still tries to match to the full album).
      search_for_tracks = true;
      # Prepend artist name when searching for albums
      album_prepend_artist = false;
      track_prepend_artist = true;
      # Search modes: all, incrementing_page, first_page
      # "all": search for every wanted record, "first_page": repeatedly searches the first page, "incrementing_page": starts with the first page and increments on each run.
      search_type = "incrementing_page";
      # Albums to process per run
      number_of_albums_to_grab = 10;
      # Unmonitor album on failure; logs to failure_list.txt
      remove_wanted_on_failure = false;
      # Blacklist words in album or track titles (case-insensitive)
      title_blacklist = "";
      # Lidarr search source: "missing" or "cutoff_unmet"
      search_source = "missing";
    };

    "Logging" = {
      # Passed to Python's logging.basicConfig()
      # See: https://docs.python.org/3/library/logging.html
      level = "INFO";
      format = "[%(levelname)s|%(module)s|L%(lineno)d] %(asctime)s: %(message)s";
      datefmt = "%Y-%m-%dT%H:%M:%S%z";
    };
  };

  configDir = pkgs.writeTextDir "config.ini" configFile.text;
in {
  options.services.soularr = {
    enable = mkEnableOption "Enable Soularr service";

    lidarr.apiKey = mkOption {
      type = types.str;
      description = "The api key for Lidarr";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.custom.soularr;
      defaultText = literalExpression "pkgs.custom.soularr";
      description = ''
        The package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      timers.soularr = {
        timerConfig = {
          OnCalendar = "*:0/5";
        };
      };

      services.soularr = {
        description = "Python script that connects Lidarr with Soulseek";
        documentation = ["https://soularr.net"];

        wantedBy = ["timers.target"];

        serviceConfig = let
          workingDir = "/var/lib/soularr";
        in {
          Type = "oneshot";
          User = "soularr";
          Group = "soularr";

          StateDirectory = "soularr";

          ExecStart = "${getExe cfg.package} --config-dir ${configDir} --var-dir ${workingDir}";

          ReadWritePaths = [workingDir];
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictNamespaces = true;
          RestrictSUIDSGID = true;
        };
      };
    };

    users.users = {
      soularr = {
        group = "soularr";

        isSystemUser = true;
      };
    };

    users.groups = {
      soularr = {};
    };
  };
}
