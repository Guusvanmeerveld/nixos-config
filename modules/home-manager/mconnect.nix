{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.mconnect;

  settingsFormat =
    pkgs.formats.ini {};

  settings =
    {
      main = {
        debug = 1;
      };
    }
    // cfg.settings;
in {
  options = {
    programs.mconnect = {
      enable = lib.mkEnableOption "Enable MConnect, a KDE connect server";

      package = lib.mkPackageOption pkgs "mconnect" {};

      settings = lib.mkOption {
        type = settingsFormat.type;
        default = {};
        description = "Configure program. For sample config, check https://github.com/grimpy/mconnect/blob/master/mconnect.conf";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services = {
      mconnect = {
        Unit = {
          Description = "KDE Connect protocol implementation in Vala/C ";
          Documentation = "https://github.com/grimpy/mconnect";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${cfg.package}/bin/mconnect";
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };

    xdg.configFile."mconnect/mconnect.conf".source = settingsFormat.generate "mconnect-settings" settings;
  };
}
