{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.samba.server;
in {
  options = {
    custom.services.samba.server = {
      enable = lib.mkEnableOption "Enable Samba file sharing server";

      shares = lib.mkOption {
        type = with lib.types; attrsOf str;
        description = "Paths to share using samba";
        default = {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.samba = let
      hostname = config.networking.hostName;
    in {
      enable = true;
      openFirewall = true;

      settings = lib.mkMerge [
        {
          global = {
            "invalid users" = [
              "root"
            ];

            security = "user";
            "workgroup" = "WORKGROUP";
            "server string" = hostname;
            "netbios name" = hostname;

            "guest account" = "nobody";
            "map to guest" = "bad user";

            "hosts allow" = ["192.168.2." "127.0.0.1" "localhost"];
            "hosts deny" = ["0.0.0.0/0"];
          };
        }

        (lib.mapAttrs (
            _share: path: {
              inherit path;

              browseable = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
            }
          )
          cfg.shares)
      ];
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
