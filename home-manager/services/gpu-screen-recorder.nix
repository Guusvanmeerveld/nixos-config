{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.services.gpu-screen-recorder;

  saveReplayScript = pkgs.writeShellApplication {
    name = "gsr-save-replay";

    runtimeInputs = with pkgs; [
      killall
      libnotify
    ];

    text = ''
      killall -SIGUSR1 gpu-screen-recorder
      notify-send -t 3000 -u low 'GPU Screen Recorder' "Replay saved to \"${cfg.options.outputDir}\"" -i com.dec05eba.gpu_screen_recorder -a 'GPU Screen Recorder'
    '';
  };
in {
  options = {
    custom.services.gpu-screen-recorder = {
      enable = lib.mkEnableOption "Enable GPU screen recorder";

      options = {
        outputDir = lib.mkOption {
          type = lib.types.str;
          description = "The ouput directory where the videos will be placed";
          default = "${config.home.homeDirectory}/Videos/Replays";
        };

        window = lib.mkOption {
          type = lib.types.str;
          description = "The window to record";
          default = "portal";
        };

        framerate = lib.mkOption {
          type = lib.types.ints.unsigned;
          description = "The framerate to record at";
          default = 60;
        };

        quality = lib.mkOption {
          type = lib.types.oneOf [(lib.types.enum ["medium" "high" "very_high" "ultra"]) lib.types.number];
          description = "The video quality to record at";
          default = 15 * 1024;
        };

        format = lib.mkOption {
          type = lib.types.enum ["mkv" "mp4"];
          description = "The format to output the recording in";
          default = "mp4";
        };

        videoCodec = lib.mkOption {
          type = lib.types.enum ["auto" "h264" "hevc" "av1" "hevc_hdr" "av1_hdr"];
          description = "The video codec to record in";
          default = "auto";
        };

        audio = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "The audio devices to capture";
          default = ["game_sink.monitor" "default_input"];
        };

        audioCodec = lib.mkOption {
          type = lib.types.enum ["aac" "opus" "flac"];
          description = "The audio codec to record in";
          default = "aac";
        };

        replayMode = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to continually record and save replays";
            default = true;
          };

          bufferSize = lib.mkOption {
            type = lib.types.ints.unsigned;
            description = "How large of a buffer (in seconds) to store of the recording at each moment";
            default = 60;
          };
        };

        verbose = lib.mkEnableOption "Whether to verbosely print logs";

        systemdTarget = lib.mkOption {
          type = lib.types.str;
          default = config.wayland.systemd.target;
          defaultText = lib.literalExpression "config.wayland.systemd.target";
          description = ''
            Systemd target to bind to.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        package = saveReplayScript;
        keybind = "$mod+g";
      }
    ];

    services.pipewire = {
      enable = true;

      configs = {
        "10-coupled-streams" = {
          "context.modules" = [
            {
              name = "libpipewire-module-loopback";
              args = {
                "audio.position" = ["FL" "FR"];
                "capture.props" = {
                  "media.class" = "Audio/Sink";
                  "node.name" = "game_sink";
                  "node.description" = "Virtual game sink";
                };
              };
            }
          ];
        };
      };
    };

    systemd.user.services.gpu-screen-recorder = {
      Unit = {
        Description = "GPU Screen Recorder Service";
        Documentation = "https://git.dec05eba.com/gpu-screen-recorder/about/";

        After = [cfg.options.systemdTarget];
        PartOf = [cfg.options.systemdTarget];
        Before = ["sleep.target"];
      };

      Service = {
        KillSignal = "SIGINT";
        Restart = "on-failure";
        RestartSec = "30s";

        Type = "simple";

        ExecStart = pkgs.writeShellScript "start-gpu-screen-recorder" ''
          ${lib.getExe pkgs.gpu-screen-recorder} \
            ${lib.optionalString cfg.options.replayMode.enable "-r ${toString cfg.options.replayMode.bufferSize}"} \
            -k ${cfg.options.videoCodec} \
            -ac ${cfg.options.audioCodec} \
            -o ${cfg.options.outputDir} \
            -f ${toString cfg.options.framerate} \
            -bm cbr \
            -fm ${
            if cfg.options.window == "portal"
            then "content"
            else "vfr"
          } \
            -w ${cfg.options.window} \
            -restore-portal-session ${
            if cfg.options.window == "portal"
            then "yes"
            else "no"
          } \
            -c ${cfg.options.format} \
            -q ${toString cfg.options.quality} \
            -v ${
            if cfg.options.verbose
            then "yes"
            else "no"
          } \
            -a "${lib.concatStringsSep "|" cfg.options.audio}"
        '';
      };

      Install.WantedBy = [cfg.options.systemdTarget];
    };
  };
}
