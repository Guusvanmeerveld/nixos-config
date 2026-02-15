{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.cleanuparr;
in {
  options = {
    services.cleanuparr = {
      enable = lib.mkEnableOption "Enable Cleanuparr, a cleanup service for the *arr applications";

      package = lib.mkPackageOption pkgs.custom "cleanuparr" {};

      port = lib.mkOption {
        type = lib.types.ints.u16;
        default = 11011;
        description = "Port to run the service on";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "cleanuparr";
        description = "User account under which Cleanuparr runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "cleanuparr";
        description = "Group under which Cleanuparr runs.";
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/cleanuparr";
        description = ''
          Base data directory.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      tmpfiles.settings.cleanuparr = {
        ${cfg.dataDir}."d" = {
          mode = "700";
          inherit (cfg) user group;
        };

        "${cfg.dataDir}/wwwroot"."L+" = {
          mode = "700";
          argument = "${cfg.package}/wwwroot";
          inherit (cfg) user group;
        };
      };

      services.cleanuparr = {
        description = "Cleanup service for *arr applications";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        environment = {
          PORT = toString cfg.port;
          BIND_ADDRESS = "0.0.0.0";
          BASE_PATH = "";
        };

        serviceConfig = {
          Type = "simple";

          User = cfg.user;
          Group = cfg.group;
          UMask = "0077";

          WorkingDirectory = cfg.dataDir;
          ExecStart = "${lib.getExe cfg.package}";
          Restart = "on-failure";
          TimeoutSec = 15;

          NoNewPrivileges = true;
          SystemCallArchitectures = "native";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = !config.boot.isContainer;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          ProtectControlGroups = !config.boot.isContainer;
          ProtectSystem = "strict";
          ProtectHostname = true;
          ProtectKernelLogs = !config.boot.isContainer;
          ProtectKernelModules = !config.boot.isContainer;
          ProtectKernelTunables = !config.boot.isContainer;
          LockPersonality = true;
          PrivateTmp = !config.boot.isContainer;
          PrivateDevices = true;
          PrivateUsers = true;
          RemoveIPC = true;
          ReadWritePaths = [cfg.dataDir];

          SystemCallFilter = [
            "~@clock"
            "~@aio"
            "~@chown"
            "~@cpu-emulation"
            "~@debug"
            "~@keyring"
            "~@memlock"
            "~@module"
            "~@mount"
            "~@obsolete"
            "~@privileged"
            "~@raw-io"
            "~@reboot"
            "~@setuid"
            "~@swap"
          ];
          SystemCallErrorNumber = "EPERM";
        };
      };
    };

    users.users = lib.mkIf (cfg.user == "cleanuparr") {
      cleanuparr = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "cleanuparr") {
      cleanuparr = {};
    };
  };
}
