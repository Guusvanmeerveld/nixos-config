{
  inputs,
  pkgs,
  ...
}: let
  package = pkgs.kodi-gbm.withPackages (kodiPkgs:
    (with kodiPkgs; [
      jellyfin
      youtube
      netflix
    ])
    ++ (with pkgs.custom.kodiPackages; [hue-service]));
in {
  imports = [inputs.home-manager.nixosModules.default];

  config = {
    environment.systemPackages = [package];

    users.extraUsers.kodi = {
      isNormalUser = true;
      extraGroups = ["video" "input" "audio" "disk" "network" "optical" "power" "storage" "tty"];
    };

    systemd.services.kodi = {
      description = "Kodi media center";

      wantedBy = ["multi-user.target"];

      after = [
        "remote-fs.target"
        "systemd-user-sessions.service"
        "network-online.target"
        "nss-lookup.target"
        "sound.target"
        "bluetooth.target"
        "polkit.service"
        "upower.service"
        "mysqld.service"
        "lircd.service"
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

    home-manager.users.kodi = {pkgs, ...}: {
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "24.05";
    };

    services.udev.extraRules = ''
      # allow access to raspi cec device for video group (and optionally register it as a systemd device, used below)
      KERNEL=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"

      SUBSYSTEM=="vc-sm",GROUP="video",MODE="0660"
      SUBSYSTEM=="tty",KERNEL=="tty[0-9]*",GROUP="tty",MODE="0660"
      SUBSYSTEM=="dma_heap",KERNEL=="linux*",GROUP="video",MODE="0660"
      SUBSYSTEM=="dma_heap",KERNEL=="system",GROUP="video",MODE="0660"
    '';

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "kodi") {
          polkit.log("action=" + action);
          polkit.log("subject=" + subject);

          if (action.id.indexOf("org.freedesktop.login1.") == 0) {
              return polkit.Result.YES;
          }

          if (action.id.indexOf("org.freedesktop.udisks.") == 0) {
              return polkit.Result.YES;
          }

          if (action.id.indexOf("org.freedesktop.udisks2.") == 0) {
              return polkit.Result.YES;
          }
        }
      });
    '';
  };
}
