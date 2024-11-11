{
  config,
  lib,
  pkgs,
  ...
}: let
  mpdConfig = config.services.mpd;

  cfg = config.services.mpd.mpris;
in {
  options = {
    services.mpd.mpris = {
      enable = lib.mkEnableOption "Enable MPRIS support for mpd";

      host = lib.mkOption {
        type = lib.types.str;
        default = mpdConfig.network.listenAddress;
      };

      port = lib.mkOption {
        type = lib.types.ints.u16;
        default = mpdConfig.network.port;
      };

      musicDirectory = lib.mkOption {
        type = lib.types.str;
        default = mpdConfig.musicDirectory;
      };

      package = lib.mkPackageOption pkgs.custom "mpdris2" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services.mpdris2 = {
      Unit = {
        Description = "mpDris2 - Music Player Daemon D-Bus bridge";
        Documentation = "https://github.com/eonpatapon/mpDris2";
        PartOf = "mpd.target";
        After = "mpd.target";
      };

      Service = {
        ExecStart = "${lib.getExe cfg.package} --use-journal --host='${cfg.host}' --port='${toString cfg.port}' --music-dir='${cfg.musicDirectory}'";
        Restart = "on-failure";
        BusName = "org.mpris.MediaPlayer2.mpd";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
