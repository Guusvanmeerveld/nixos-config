{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.clipmon;

  package = pkgs.clipmon;
in {
  options = {
    custom.wm.wayland.clipmon = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.enable;
        description = "Enable clipman clipboard service";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [package];

    systemd.user.services.clipmon = {
      Unit = {
        Description = "Clipboard monitor for Wayland";
        Documentation = "https://sr.ht/~whynothugo/clipmon";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
      };

      Service = {
        Slice = "session.slice";
        ExecStart = "${package}/bin/clipmon";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
