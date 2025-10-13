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

              excluded = mkOption {
                type = listOf str;
                default = [];
                description = "List of files to NOT back up";
              };

              timer = mkOption {
                type = str;
                default = "05:00";
                description = "List of files to back up";
              };

              sqliteDBs = mkOption {
                type = listOf str;
                default = [];
                description = "List of sqlite db's to back up";
              };

              postgresDBs = mkOption {
                type = listOf (submodule (_: {
                  options = {
                    dbName = mkOption {
                      type = str;
                      description = "The name of the database";
                    };

                    user = mkOption {
                      type = str;
                      default = cfg.${name}.user;
                      description = "The user to run the backup as";
                    };
                  };
                }));
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
                default = name;
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
    inherit (lib) mkIf mapAttrs optionalString optional optionals getExe concatStringsSep concatStrings;
  in
    mkIf cfg.enable {
      services.restic.backups =
        mapAttrs (
          name: {
            files,
            excluded,
            services,
            sqliteDBs,
            postgresDBs,
            passwordFile,
            timer,
            user,
            location,
            ...
          }: let
            needsToRestartServices = services != [];
            needsSqliteBackup = sqliteDBs != [];
            needsPostgresBackup = postgresDBs != [];
            needsDBBackup = needsPostgresBackup || needsSqliteBackup;
          in {
            inherit passwordFile user;

            backupPrepareCommand = mkIf needsToRestartServices (getExe (pkgs.writeShellApplication {
              name = "prepare-backup-${name}";

              runtimeInputs = with pkgs; [systemd];

              text = ''
                ${optionalString needsToRestartServices ''
                  systemctl stop ${concatStringsSep " " services}
                ''}
              '';
            }));

            backupCleanupCommand = mkIf needsToRestartServices (getExe (pkgs.writeShellApplication {
              name = "cleanup-backup-${name}";

              runtimeInputs = with pkgs; [systemd];

              text = ''
                ${optionalString needsToRestartServices ''
                  systemctl start ${concatStringsSep " " services}
                ''}
              '';
            }));

            paths = files;
            exclude = excluded;

            dynamicFilesFrom = mkIf needsDBBackup (getExe (pkgs.writeShellApplication {
              name = "${name}-backup-dynamic-files";

              runtimeInputs = with pkgs; ([findutils]
                ++ (optionals needsPostgresBackup [postgresql sudo-rs coreutils])
                ++ (optional needsSqliteBackup sqlite));

              text = let
                sqliteBackupScript = optional needsSqliteBackup (
                  concatStringsSep "\n" (lib.imap0
                    (i: location: ''
                      sqlite3 ${location} ".backup '/tmp/${name}_${toString i}_db.sqlite3.bak'"
                    '')
                    sqliteDBs)
                );

                postgresBackupScript = optional needsPostgresBackup (
                  concatStringsSep "\n" (map
                    ({
                      dbName,
                      user,
                    }: ''
                      sudo -u ${user} pg_dump ${dbName} | sudo -u ${user} tee '/tmp/${name}_${toString dbName}_db.psql.bak' > /dev/null
                    '')
                    postgresDBs)
                );
              in ''
                umask 077

                ${concatStrings (sqliteBackupScript ++ postgresBackupScript)}

                find ${
                  concatStringsSep " "
                  ((optional needsSqliteBackup "/tmp/${name}_*_db.sqlite3.bak")
                    ++ (optional needsPostgresBackup "/tmp/${name}_*_db.psql.bak"))
                }
              '';
            }));

            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 5"
              "--keep-monthly 12"
            ];

            initialize = true;

            repository = "${cfg.repository}/${location}";

            timerConfig = {
              OnCalendar = timer;
              RandomizedDelaySec = "1h";
            };

            environmentFile = cfg.restEnvFile;
          }
        )
        cfg.backups;
    };
}
