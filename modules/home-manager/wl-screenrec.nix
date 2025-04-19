{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.wl-screenrec;

  pactl = "${pkgs.pulseaudio}/bin/pactl";

  filename = ''${cfg.options.outputDir}/wlsr-recording-"$(date +'%Y-%m-%d_%R:%S')".mp4'';

  saveReplayScript = pkgs.writeShellApplication {
    name = "wlsr-save-replay";

    runtimeInputs = with pkgs; [
      killall
      libnotify
    ];

    text = ''
      killall -USR1 wl-screenrec
      notify-send -t 3000 -u low 'Wayland Screenrecorder' "Replay saved and recording to: '${cfg.options.outputDir}'" -i com.dec05eba.gpu_screen_recorder -a 'Wayland Screenrecorder'
    '';
  };
in {
  options = {
    services.wl-screenrec = {
      enable = lib.mkEnableOption "Enable Wayland Screenrecorder";

      package = lib.mkPackageOption pkgs "wl-screenrec" {};

      options = {
        outputDir = lib.mkOption {
          type = lib.types.str;
          description = "The ouput directory where the videos will be placed";
          default = "${config.home.homeDirectory}/Videos/Replays";
        };

        output = lib.mkOption {
          type = lib.types.str;
          description = "The output to record";
        };

        codec = lib.mkOption {
          type = lib.types.enum ["auto" "avc" "hevc" "vp8" "vp9" "av1"];
          description = "The video codec to record in";
          default = "auto";
        };

        audio = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "The audio devices to capture";
          default = ["$(${pactl} get-default-sink).monitor"];
        };

        history = lib.mkOption {
          type = lib.types.int;
          description = "How many seconds of history to store in memory";
          default = 300;
        };

        verbose = lib.mkEnableOption "Whether to verbosely print logs";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      saveReplayScript
      cfg.package
    ];

    systemd.user.services.wl-screenrec = {
      Unit = {
        Description = "Wayland Screenrecorder Service";
        Documentation = "https://github.com/russelltg/wl-screenrec";

        After = ["pipewire.service"];
        Wants = ["pipewire.service"];
      };

      Service = {
        KillSignal = "SIGINT";
        Restart = "on-failure";
        RestartSec = "30s";

        Type = "simple";

        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "start-wlsr";

          runtimeInputs = [cfg.package pkgs.coreutils];

          text = ''
            wl-screenrec \
              --filename ${filename} \
              --output ${cfg.options.output} \
              --history ${toString cfg.options.history} \
              ${lib.optionalString cfg.options.verbose "-v"} \
              --codec ${cfg.options.codec} \
              ${lib.optionalString ((lib.length cfg.options.audio) != 0) "--audio"}
          '';
          # ${lib.optionalString ((lib.length cfg.options.audio) != 0) ''--audio-device "${lib.concatStringsSep "|" cfg.options.audio}"''} \
        });
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
