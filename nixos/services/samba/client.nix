{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.samba.client;
in {
  options = {
    custom.services.samba.client = {
      enable = lib.mkEnableOption "Enable Samba share mount client";

      credentialsFile = lib.mkOption {
        type = lib.types.str;
        description = "The location of the credentials file";
        default = "/secrets/samba/client/default";
      };

      shares = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            host = {
              dir = lib.mkOption {
                type = lib.types.str;
                description = "The location of the mount on the host";
              };

              uid = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.u16;
                default = null;
              };

              gid = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.u16;
                default = null;
              };

              dirMode = lib.mkOption {
                type = lib.types.str;
                default = "0755";
              };

              fileMode = lib.mkOption {
                type = lib.types.str;
                default = "0644";
              };

              credentialsFile = lib.mkOption {
                type = lib.types.str;
                description = "The location of the credentials file";
                default = cfg.credentialsFile;
              };
            };

            remote = {
              host = lib.mkOption {
                type = lib.types.str;
                description = "The hostname of the machine running the samba server";
              };

              dir = lib.mkOption {
                type = lib.types.str;
                description = "The location of the mount on the host";
              };
            };
          };
        });

        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems = builtins.listToAttrs (map (share: {
        name = share.host.dir;
        value = {
          options = [
            (lib.concatStringsSep "," [
              "noauto"
              "x-systemd.automount"
              "x-systemd.idle-timeout=60"
              "x-systemd.device-timeout=5s"
              "x-systemd.mount-timeout=5s"
              "credentials=${share.host.credentialsFile}"
              "uid=${toString share.host.uid}"
              "gid=${toString share.host.gid}"
              "dir_mode=${share.host.dirMode}"
              "file_mode=${share.host.fileMode}"
            ])
          ];

          device = "//${share.remote.host}/${share.remote.dir}";
          fsType = "cifs";
        };
      })
      cfg.shares);
  };
}
