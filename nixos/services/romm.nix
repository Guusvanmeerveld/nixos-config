{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.romm;
in {
  options = {
    custom.services.romm = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the RomM service";

      port = mkOption {
        type = types.ints.u16;
        default = 8090;
        description = "The port to run the service on";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "romm";
        description = "User account under which romm runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "romm";
        description = "Group under which romm runs.";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/romm";
        description = "Where the data for the application will be stored";
      };

      caddy.url = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf getExe;
  in
    mkIf cfg.enable {
      systemd = {
        services.podman-romm-network = mkIf config.virtualisation.podman.enable {
          description = "Create the network bridge for romm.";
          after = ["network.target"];
          before = ["podman-romm.service" "podman-romm-db.service"];
          wantedBy = ["multi-user.target"];

          serviceConfig.Type = "oneshot";

          script = ''
            # Put a true at the end to prevent getting non-zero return code, which will crash the whole service.
            check=$(${getExe pkgs.podman} network ls | grep "romm-bridge" || true)

            if [ -z "$check" ]; then
              ${getExe pkgs.podman} network create romm-bridge
            else
              echo "romm-bridge already exists"
            fi
          '';
        };

        # tmpfiles.settings.romm = {
        #   "${cfg.dataDir}/library"."d" = {
        #     mode = "700";
        #     inherit (cfg) user group;
        #   };

        #   "${cfg.dataDir}/resources"."d" = {
        #     mode = "700";
        #     inherit (cfg) user group;
        #   };

        #   "${cfg.dataDir}/assets"."d" = {
        #     mode = "700";
        #     inherit (cfg) user group;
        #   };

        #   "${cfg.dataDir}/config"."d" = {
        #     mode = "700";
        #     inherit (cfg) user group;
        #   };

        #   "${cfg.dataDir}/redis"."d" = {
        #     mode = "700";
        #     inherit (cfg) user group;
        #   };

        #   "${cfg.dataDir}/db"."d" = {
        #     mode = "700";
        #     inherit (cfg) user group;
        #   };
        # };
      };

      users.users = lib.mkIf (cfg.user == "romm") {
        romm = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };

      users.groups = lib.mkIf (cfg.group == "romm") {
        romm = {};
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            ${cfg.caddy.url} = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.port}
              '';
            };
          };
        };
      };

      virtualisation.oci-containers.containers = {
        romm = let
          package = pkgs.custom.dockerPackages.romm;
        in {
          image = "${package.imageName}:${package.imageTag}";
          imageFile = package;

          extraOptions = ["--network=romm-bridge"];

          environment = {
            DB_HOST = "romm-db";
            DB_NAME = "romm";
            DB_USER = "romm";
            DB_PASSWD = "romm";

            HASHEOUS_API_ENABLED = toString true;
            TGDB_API_ENABLED = toString true;
            FLASHPOINT_API_ENABLED = toString true;
            LAUNCHBOX_API_ENABLED = toString true;
            PLAYMATCH_API_ENABLED = toString true;
            HLTB_API_ENABLED = toString true;
          };

          environmentFiles = [
            "/secrets/romm"
          ];

          ports = [
            "${toString cfg.port}:8080"
          ];

          volumes = [
            "${cfg.dataDir}/resources:/romm/resources"
            "${cfg.dataDir}/library:/romm/library"
            "${cfg.dataDir}/assets:/romm/assets"
            "${cfg.dataDir}/config:/romm/config"
            "${cfg.dataDir}/redis:/redis-data"
          ];
        };

        romm-db = {
          image = "mariadb:latest";

          extraOptions = ["--network=romm-bridge"];

          environment = {
            MARIADB_ROOT_PASSWORD = "romm";
            MARIADB_DATABASE = "romm";
            MARIADB_USER = "romm";
            MARIADB_PASSWORD = "romm";
          };

          volumes = [
            "${cfg.dataDir}/db:/var/lib/mysql"
          ];
        };
      };
    };
}
