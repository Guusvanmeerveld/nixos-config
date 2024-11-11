{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.clipmon;
in {
  options = {
    services.clipmon = {
      enable = lib.mkEnableOption "Enable clipboard monitor";

      package = lib.mkPackageOption pkgs.custom "clipmon" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services.clipmon = {
      Unit = {
        Description = "Clipboard monitor for Wayland";
        Documentation = "https://sr.ht/~whynothugo/clipmon";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
      };

      Service = {
        Slice = "session.slice";
        ExecStart = lib.getExe cfg.package;
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
