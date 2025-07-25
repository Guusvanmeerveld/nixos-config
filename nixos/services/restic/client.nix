{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.restic.client;
in {
  options = {
    custom.services.restic.client = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Restic client service";

      backups = mkOption {
        default = {};
        type = with types;
          attrsOf (submodule ({name, ...}: {
            options = {
              files = mkOption {
                type = listOf str;
                default = [];
                description = "List of files to back up";
              };

              sqliteDBs = mkOption {
                type = listOf str;
                default = [];
                description = "List of sqlite db's to back up";
              };

              postgresDBs = mkOption {
                type = listOf str;
                default = [];
                description = "List of PostgresQL db's to back up";
              };

              services = mkOption {
                type = listOf str;
                default = [];
                description = "List of systemd services that should be stopped while the backup is running";
              };

              user = mkOption {
                type = str;
                default = "root";
                description = "The user to run the backup as";
              };

              location = mkOption {
                type = str;
                description = "Name of the location to store the backup";
                example = "jellyfin";
              };

              passwordFile = mkOption {
                type = str;
                description = "Path to the file containing the repository password";
                default = "/secrets/restic/${name}/passwordFile";
              };
            };
          }));
      };

      repository = mkOption {
        type = types.str;
        default = "rest:https://restic.chd";
      };

      restEnvFile = mkOption {
        type = types.path;
        default = "/secrets/restic/client/restEnvFile";
      };
    };
  };

  config = let
    inherit (lib) mkIf mapAttrs optionalString getExe concatStringsSep;
  in
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [restic];

      services.restic.backups =
        mapAttrs (
          name: {
            files,
            services,
            passwordFile,
            location,
          }: {
            inherit passwordFile;

            backupPrepareCommand = getExe (pkgs.writeShellApplication {
              name = "prepare-backup-${name}";

              runtimeInputs = with pkgs; [systemd];

              text = ''
                ${optionalString (services != []) ''
                  systemctl stop ${concatStringsSep " " services}
                ''}
              '';
            });

            backupCleanupCommand = getExe (pkgs.writeShellApplication {
              name = "cleanup-backup-${name}";

              runtimeInputs = with pkgs; [systemd];

              text = ''
                ${optionalString (services != []) ''
                  systemctl start ${concatStringsSep " " services}
                ''}
              '';
            });

            paths = files;

            initialize = true;

            repository = "${cfg.repository}/${location}";

            environmentFile = cfg.restEnvFile;
          }
        )
        cfg.backups;
    };
}
