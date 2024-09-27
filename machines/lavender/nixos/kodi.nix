{
  pkgs,
  lib,
  ...
}: let
  package = pkgs.kodi-gbm.withPackages (kodiPkgs:
    (with kodiPkgs; [
      jellyfin
      youtube
    ])
    ++ [pkgs.hue-service]);
in {
  config = {
    environment.systemPackages = [package];

    users.extraUsers.kodi = {
      isNormalUser = true;
      extraGroups = ["video" "input" "audio"];
    };

    systemd.services.kodi = {
      description = "Kodi media center";

      wantedBy = ["multi-user.target"];

      after = [
        "network-online.target"
        "sound.target"
        "systemd-user-sessions.service"
      ];

      wants = [
        "network-online.target"
      ];

      serviceConfig = {
        Type = "simple";
        User = "kodi";
        ExecStart = "${package}/bin/kodi-standalone";
        Restart = "always";
        TimeoutStopSec = "15s";
        TimeoutStopFailureMode = "kill";

        # Hardening
      };
    };

    # services.xserver = {
    #  enable = true;
    #
    #  desktopManager = {
    #    session = [{
    #      name = "kodi";
    #      start = ''
    #        LIRC_SOCKET_PATH=/run/lirc/lircd ${kodi}/bin/kodi --standalone --audio-backend=pipewire &
    #        waitPID=$!
    #      '';
    #    }];
    #  };
    #
    #  displayManager = {
    #    autoLogin.enable = true;
    #    autoLogin.user = "kodi";
    #  };
    # };

    # Wayland
    # Wayland is currently only able to operate on one resolution which is not desired.
    # services = {
    #    cage = let
    #    program = pkgs.writeShellScript "start-kodi" ''
    #        ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --mode 3840x2160@30
    #        ${kodi}/bin/kodi-standalone
    #    ''; in {
    #        inherit program;
    #
    #        enable = true;
    #
    #        user = "kodi";
    #    };
    # };
  };
}
