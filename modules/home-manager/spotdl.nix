{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.spotify-downloader;
in {
  options = {
    services.spotify-downloader = {
      enable = lib.mkEnableOption "Enable Spotify downloader service";

      package = lib.mkPackageOption pkgs "spotdl" {};

      directory = lib.mkOption {
        type = lib.types.str;
        default = config.xdg.userDirs.music + "/Spotify";
      };

      format = lib.mkOption {
        type = lib.types.enum ["mp3" "flac" "ogg" "opus" "m4a" "wav"];
        default = "m4a";
      };

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
      };

      secrets = {
        enable = lib.mkEnableOption "Enable use of custom client secret";

        file = lib.mkOption {
          type = lib.types.str;
        };
      };

      playlists = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "A list of playlist id's";
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user = {
      timers."spotdl" = {
        Unit = {
          Description = "Timer for Spotify media downloader";
        };

        Timer = {
          OnCalendar = cfg.schedule;
          Persistent = true;
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };

      services."spotdl" = let
        script = pkgs.writeShellApplication {
          name = "spotdl-download";

          runtimeInputs = with pkgs; [spotdl];

          text = ''
            spotdl download ${lib.concatStringsSep " " (map (id: "https://open.spotify.com/playlist/${id}") cfg.playlists)} \
              --format ${cfg.format} \
              --output "${cfg.directory}/{list-name}/{track-id}.{output-ext}" \
              --overwrite metadata \
              --use-cache-file \
              ${lib.optionalString cfg.secrets.enable ''
              --client-id "$CLIENT_ID" \
              --client-secret "$CLIENT_SECRET"
            ''}
          '';
        };
      in {
        Unit = {
          Description = "Download media files from Spotify";
        };

        Service = {
          Type = "oneshot";
          EnvironmentFile = lib.mkIf cfg.secrets.enable cfg.secrets.file;
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.directory}";
          ExecStart = lib.getExe script;
        };
      };
    };
  };
}
