{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.custom.services.qbittorrent;
in {
  options = {
    custom.services.qbittorrent = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable qBittorrent";

      webUIPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 4545;
        description = "The port to run the web ui on";
      };

      saveDir = mkOption {
        type = types.path;
        default = "/var/lib/qbittorrent/downloads";
        description = ''
          The directory where qBittorrent stores its data files.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = "Open qBittorrent ports in firewall";
      };

      caddy.url = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      custom.services.restic.client.backups.qbittorrent = {
        files = [
          config.services.qbittorrent.profileDir
        ];
      };

      systemd.services.qbittorrent = {
        serviceConfig = {
          MemoryHigh = "3G";
          MemoryMax = "4G";
        };
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = let
              address =
                if config.services.qbittorrent.serverConfig.Preferences.WebUI.Address != null
                then config.services.qbittorrent.serverConfig.Preferences.WebUI.Address
                else "localhost";
            in {
              extraConfig = ''
                reverse_proxy http://${address}:${toString cfg.webUIPort}
              '';
            };
          };
        };

        qbittorrent = {
          enable = true;

          inherit (cfg) openFirewall;

          profileDir = "/var/lib/qbittorrent";

          webuiPort = cfg.webUIPort;

          serverConfig = {
            LegalNotice.Accepted = true;

            Application = {
              MemoryWorkingSetLimit = 4096;
            };

            BitTorrent = {
              ExcludedFileNamesEnabled = true;

              Session = {
                AnonymousModeEnabled = true;

                DefaultSavePath = cfg.saveDir;
                # Enable automatic torrent management mode
                DisableAutoTMMByDefault = false;
                # Relocate files automatically when save path changed
                DisableAutoTMMTriggers = {
                  CategorySavePathChanged = false;
                  DefaultSavePathChanged = false;
                };

                MultiConnectionsPerIp = true;
                MaxActiveUploads = 8;

                GlobalUPSpeedLimit = 62 * (1000 - 20);
                GlobalDLSpeedLimit = 100 * (1000 - 20);

                AlternativeGlobalUPSpeedLimit = 5 * (1000 - 20);
                AlternativeGlobalDLSpeedLimit = 10 * (1000 - 20);

                DiskIOType = "Posix";

                ExcludedFileNames = lib.concatStringsSep ", " (lib.splitString "\n" (builtins.readFile "${inputs.cleanuparr}/blacklist"));
              };
            };

            Preferences = {
              WebUI = {
                Username = "admin";
                Password_PBKDF2 = "@ByteArray(tc2Q2C5ty2vsc4lMKY06lQ==:ubZ2/CKM5955c4DfpARBgRTcOwo9locV7m+s0/fpCAGQiTzX5vPAzhYuLN5blTJ0qAcrIImLOcN9NCCxqOElAA==)";

                AlternativeUIEnabled = true;
                RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
              };

              General.Locale = "en";
            };
          };
        };
      };
    };
}
