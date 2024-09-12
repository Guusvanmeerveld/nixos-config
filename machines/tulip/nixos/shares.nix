{
  config,
  pkgs,
  ...
}: let
  # this line prevents hanging on network split
  automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  options = "${automount_opts},credentials=/etc/nixos/smb-secrets";
in {
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems = {
    "/mnt/share/media" = {
      options = [options];

      device = "//orchid/media";
      fsType = "cifs";
    };

    "/mnt/share/apps/nextcloud" = let
      nextcloudId = toString 33;
      dataDirPermissions = "0770";
    in {
      options = ["${options},uid=${nextcloudId},gid=${nextcloudId},dir_mode=${dataDirPermissions},file_mode=${dataDirPermissions}"];

      device = "//orchid/nextcloud";
      fsType = "cifs";
    };

    "/mnt/share/apps/gitea" = let
    in {
      options = ["${options},uid=${toString config.users.users.gitea.uid},gid=${toString config.users.groups.gitea.gid},dir_mode=0755,file_mode=0644"];

      device = "//orchid/gitea";
      fsType = "cifs";
    };
  };
}
