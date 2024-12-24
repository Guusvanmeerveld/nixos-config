{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.autoUpdate;

  configLocation = "/tmp/home-manager-updater";

  updaterScript = pkgs.writeShellApplication {
    name = "home-manager-updater";

    runtimeInputs = with pkgs; [zenity home-manager nix git nvd];

    text = ''
      export XDG_STATE_HOME='${config.xdg.stateHome}'
      export HMU_CONFIG_LOCATION='${configLocation}'
      export HMU_REPO_URL='${cfg.repoUrl}'

      ${./updater.sh} "$@"
    '';
  };
in {
  options = {
    services.autoUpdate = {
      enable = lib.mkEnableOption "Enable Home-Manager auto updating service";

      repoUrl = lib.mkOption {
        type = lib.types.str;

        default = "https://github.com/guusvanmeerveld/nixos-config";
      };

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "daily";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [updaterScript];

    # systemd.user = {
    #   timers."home-manager-updater" = {
    #     Unit = {
    #       Description = "Timer for Home-Manager updating service";
    #     };

    #     Timer = {
    #       Persistent = true;
    #       OnCalendar = cfg.schedule;
    #     };

    #     Install = {
    #       WantedBy = ["timers.target"];
    #     };
    #   };

    #   services."home-manager-updater" = {
    #     Service = {
    #       Type = "oneshot";
    #       ExecStart = lib.getExe updaterScript;
    #     };
    #   };
    # };
  };
}
