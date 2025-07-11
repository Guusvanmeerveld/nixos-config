{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.syncthing;

  devices = {
    "phone" = {
      id = "PYX3DUO-3KE5MGU-5DSYFSX-CEDXULA-KSABFMJ-4C3H2CZ-LHCXPGW-DWIZHQC";
      addresses = ["tcp://10.10.10.4:22000"];
    };

    "thuisthuis" = {
      id = "IVEIEZR-TE6NDJN-5IMPE3W-6DVX5GV-PSLULEC-54YWZX3-5B745Y5-6YMAFAH";
      addresses = ["tcp://10.10.10.6:22000"];
    };

    "laptop" = {
      id = "FYHUOAV-WN6KYQV-SLVAUIW-F5JZO65-3AWESRR-BEYDKGN-5XNLV67-AURU5A2";
      addresses = ["tcp://10.10.10.3:22000"];
    };

    "desktop" = {
      id = "TGVX2VH-ABGT3IS-X2C6DTF-UI3NFL4-LDQ337J-M2YQBV3-OBDJSMR-7U67NQH";
      addresses = ["tcp://10.10.10.2:22000"];
    };

    "orchid" = {
      id = "DFTGINN-YXVURFW-5AOE36K-7O62WZB-KC6TVN5-PUCXPOI-BDNZW6L-HCQPSAW";
      addresses = ["tcp://10.10.10.10:22000"];
    };

    "crocus" = {
      id = "DFTGINN-YXVURFW-5AOE36K-7O62WZB-KC6TVN5-PUCXPOI-BDNZW6L-HCQPSAW";
      addresses = ["tcp://10.10.10.10:22000"];
    };

    "framework-13" = {
      id = "QBKBECQ-OW6BZ5K-RADYZVU-Y5YWXIX-TSQD3CD-PBTQA64-DTBYXQV-CEME4QK";
      addresses = ["tcp://10.10.10.12:22000"];
    };
  };

  folders = {
    "minecraft" = {
      label = "Minecraft";
      devices = ["orchid" "thuisthuis" "desktop" "laptop" "framework-13"];
    };

    "code" = {
      label = "Code";
      devices = ["orchid" "thuisthuis" "desktop" "laptop" "framework-13"];
    };

    "games" = {
      label = "Games";
      devices = ["orchid" "thuisthuis" "desktop" "laptop" "framework-13"];
    };

    "music" = {
      label = "Music";
      devices = ["orchid" "thuisthuis" "desktop" "laptop" "phone" "framework-13"];
    };

    "seedvault-backup" = {
      label = "Phone Backup";
      devices = ["orchid" "thuisthuis" "desktop" "phone" "framework-13"];
    };

    "dictionaries" = {
      label = "Word Dictionaries";
      devices = ["orchid" "thuisthuis" "desktop" "laptop" "framework-13"];
    };

    "firefox-profile" = {
      label = "Firefox Profile";
      devices = ["orchid" "thuisthuis" "desktop" "laptop" "framework-13"];
    };
  };
in {
  options = {
    custom.services.syncthing = {
      enable = lib.mkEnableOption "Enable Syncthing file sync client";

      user = lib.mkOption {
        type = lib.types.str;
        default = "guus";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "users";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/guus";
      };

      keyFile = lib.mkOption {
        type = lib.types.str;
        default = "/secrets/syncthing/key.pem";
      };

      certFile = lib.mkOption {
        type = lib.types.str;
        default = "/secrets/syncthing/cert.pem";
      };

      port = lib.mkOption {
        type = lib.types.ints.u16;
        default = 8384;
        description = "The port to run the service on";
      };

      caddy = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = config.services.caddy.enable;
          description = "Enable Caddy integration";
        };

        url = lib.mkOption {
          type = lib.types.str;
          description = "The external domain the service can be reached from";
        };
      };

      folders = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = {};
        description = "A list of folders that should be shared";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        description = "Open syncthing ports in firewall";
      };

      fileTransferPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 22000;
      };

      discoveryPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 21027;
      };
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [cfg.fileTransferPort cfg.discoveryPort];

    # Don't create default 'Sync' folder.
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    services = {
      caddy = lib.mkIf (cfg.enable && cfg.caddy.enable) {
        virtualHosts = {
          "${cfg.caddy.url}" = {
            extraConfig = ''
              reverse_proxy http://localhost:${toString cfg.port}
            '';
          };
        };
      };

      syncthing = lib.mkIf cfg.enable {
        enable = true;

        inherit (cfg) user;
        inherit (cfg) group;

        inherit (cfg) dataDir;

        key = cfg.keyFile;
        cert = cfg.certFile;

        guiAddress = "0.0.0.0:${toString cfg.port}";

        settings = {
          gui = {
            theme = "black";

            user = "admin";
            password = "changeme123";
          };

          options = {
            localAnnounceEnabled = false;
            urAccepted = -1;
          };

          folders = with lib;
            mapAttrs' (folderId: folderPath:
              nameValuePair folderPath (
                mkMerge [
                  (removeAttrs folders.${folderId} ["devices"])
                  {
                    devices = builtins.filter (device: device != config.networking.hostName) folders.${folderId}.devices;
                    id = folderId;
                  }
                ]
              ))
            cfg.folders;

          devices = lib.filterAttrs (device: _: device != config.networking.hostName) devices;
        };
      };
    };
  };
}
