{pkgs, ...}: let
  # this line prevents hanging on network split
  automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  options = ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
in {
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems = {
    "/mnt/share/media" = {
      inherit options;

      device = "//orchid/media";
      fsType = "cifs";
    };

    "/mnt/share/apps" = {
      inherit options;

      device = "//orchid/apps";
      fsType = "cifs";
    };
  };
}
