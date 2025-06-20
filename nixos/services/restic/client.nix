{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mergeAttrs mapAttrsToList flatten;
  cfg = config.custom.services.restic.client;

  userSecrets = flatten (mapAttrsToList (name: _: let
      homeDir = "/home/${name}";
    in [
      "${homeDir}/.ssh"
      "${homeDir}/.gnupg"
    ])
    config.custom.users);

  backups =
    mergeAttrs
    cfg.backups
    {
      secrets = {
        location = "secrets-${config.networking.hostName}";
        files = ["/secrets"] ++ userSecrets;
        passwordFile = "/secrets/restic/secrets/passwordFile";
      };
    };
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
    inherit (lib) mkIf mapAttrs;
  in
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [restic];

      services.restic.backups =
        mapAttrs (
          _: {
            files,
            passwordFile,
            location,
          }: {
            inherit passwordFile;

            paths = files;

            initialize = true;

            repository = "${cfg.repository}/${location}";

            environmentFile = cfg.restEnvFile;
          }
        )
        backups;
    };
}
