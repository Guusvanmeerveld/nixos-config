{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.gpu-screen-recorder;

  gpu-screen-recorder = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder";
  pactl = "${pkgs.pulseaudio}/bin/pactl";

  buffer-size = 5 * 60; # In seconds
in {
  options = {
    custom.applications.graphical.gpu-screen-recorder = {
      enable = lib.mkEnableOption "Enable GPU screen recorder";

      options = {
        outputDir = lib.mkOption {
          type = lib.types.str;
          description = "The ouput directory where the videos will be placed";
          default = "~/Videos/Replays";
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
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
            -r ${toString buffer-size} \
            -o ${cfg.options.outputDir} \
            -f ${toString cfg.options.framerate} \
            -w ${cfg.options.window} \
            -c ${cfg.options.format} \
            -v no
        '';
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
