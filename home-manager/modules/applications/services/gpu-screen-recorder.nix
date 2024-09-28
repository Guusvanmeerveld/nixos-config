{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.gpu-screen-recorder;

  gpu-screen-recorder = "${pkgs.unstable.gpu-screen-recorder}/bin/gpu-screen-recorder";
  pactl = "${pkgs.pulseaudio}/bin/pactl";

  createYesNoOption = value:
    if value
    then "yes"
    else "no";

  saveReplayScript = pkgs.writeShellApplication {
    name = "gsr-save-replay";

    runtimeInputs = with pkgs; [
      killall
      libnotify
    ];

    text = ''
      killall -SIGUSR1 gpu-screen-recorder
      notify-send -t 3000 -u low 'GPU Screen Recorder' "Replay saved to <br /> ${cfg.options.outputDir}" -i com.dec05eba.gpu_screen_recorder -a 'GPU Screen Recorder'
    '';
  };
in {
  options = {
    custom.applications.services.gpu-screen-recorder = {
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
          default = "screen";
        };

        framerate = lib.mkOption {
          type = lib.types.ints.unsigned;
          description = "The framerate to record at";
          default = 60;
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
          type = lib.types.str;
          description = "The audio devices to capture";
          default = ''"$(${pactl} get-default-sink).monitor|$(${pactl} get-default-source)"'';
        };

        audioCodec = lib.mkOption {
          type = lib.types.enum ["aac" "opus" "aac"];
          description = "The audio codec to record in";
          default = "aac";
        };

        replayMode = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to continually record and save replays";
            default = true;
          };

          organize = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to automatically organise replays in folders";
            default = true;
          };

          bufferSize = lib.mkOption {
            type = lib.types.ints.unsigned;
            description = "How large of a buffer (in seconds) to store of the recording at each moment";
            default = 3 * 60;
          };
        };

        verbose = lib.mkEnableOption "Whether to verbosely print logs";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      saveReplayScript
    ];

    systemd.user.services.gpu-screen-recorder = {
      Unit = {
        Description = "GPU Screen Recorder Service";
        Documentation = "https://git.dec05eba.com/gpu-screen-recorder/about/";

        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        KillSignal = "SIGINT";
        # Restart = "on-failure";
        RestartSec = "5s";

        Type = "simple";

        ExecStart = ''
          ${gpu-screen-recorder} \
            ${lib.optionalString cfg.options.replayMode.enable ''
            -r ${toString cfg.options.replayMode.bufferSize} \
            -mf ${createYesNoOption cfg.options.replayMode.organize} \''}
            -k ${cfg.options.videoCodec} \
            -ac ${cfg.options.audioCodec} \
            -o ${cfg.options.outputDir} \
            -f ${toString cfg.options.framerate} \
            -w ${cfg.options.window} \
            -c ${cfg.options.format} \
            -v ${createYesNoOption cfg.options.verbose} \
            -a ${cfg.options.audio}
        '';
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
