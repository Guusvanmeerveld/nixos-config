{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.services.motd;

  enableDocker = cfg.settings.docker != {};
in {
  options = {
    custom.services.motd = {
      enable = lib.mkEnableOption "Enable custom MOTD";

      settings = {
        docker = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          description = ''
            A list of docker containers that should be shown
            Local containers MUST start with a slash
          '';

          default = {};
        };

        fileSystems = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          description = ''
            A list of filesystems that should be shown
          '';

          default = {};
        };
      };
    };
  };

  config =
    lib.mkIf cfg.enable
    {
      programs.rust-motd = {
        enable = true;

        order = ["banner" "uptime" "filesystems" "memory"] ++ (lib.optional enableDocker "docker") ++ ["last_run"];

        settings = {
          "banner" = {
            color = "red";
            command = "${lib.getExe pkgs.hostname} | ${pkgs.figlet}/bin/figlet -f slant";
          };

          "uptime" = {
            prefix = "Up";
          };

          "docker" = lib.mkIf enableDocker cfg.settings.docker;

          "memory" = {
            swap_pos = "beside";
          };

          "filesystems" = lib.mkMerge [
            {
              root = "/";
            }
            cfg.settings.fileSystems
          ];

          "last_run" = {};
        };
      };
    };
}
