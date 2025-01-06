{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.virtualisation.docker.containers;

  networks = lib.unique (lib.flatten (lib.mapAttrsToList (_: options: lib.mapAttrsToList (serviceName: {networks, ...}: networks) options.services) cfg));

  users =
    lib.flatten (lib.mapAttrsToList (_: options: lib.mapAttrsToList (serviceName: {user, ...}: user // {serviceName = serviceName;}) options.services)
      cfg);

  usersToCreate = builtins.filter ({create, ...}: create) users;
in {
  imports = [
    inputs.docker-compose-nix.nixosModules.default
  ];

  options = {
    virtualisation.docker.containers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          services = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                image = lib.mkOption {
                  type = lib.types.str;
                };

                networks = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [];
                };

                environment = lib.mkOption {
                  type = with lib.types; (attrsOf (oneOf [str int]));
                  default = {};
                };

                forwardLocalTime = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Forwards the localtime by passing /etc/localtime to the container";
                };

                forwardHostname = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Forwards the hostname to the container";
                };

                volumes = lib.mkOption {
                  type = lib.types.listOf lib.types.str;

                  default = [];
                };

                ports = lib.mkOption {
                  type = lib.types.listOf lib.types.str;

                  default = [];
                };

                user = {
                  uid = lib.mkOption {
                    type = lib.types.int;
                  };

                  gid = lib.mkOption {
                    type = lib.types.int;
                  };

                  passEnvironment = lib.mkEnableOption "Pass the gid and uid as environment variables";
                  runContainerAsUser = lib.mkEnableOption "Run this container using the specified uid and gid";

                  create = lib.mkEnableOption "Create the user";

                  groups = lib.mkOption {
                    type = lib.types.listOf lib.types.str;

                    default = [];
                  };
                };

                memoryLimit = lib.mkOption {
                  type = lib.types.str;
                  default = "256m";
                };

                extraConfig = lib.mkOption {
                  type = lib.types.attrs;
                  default = {};
                };
              };
            });
          };
        };
      });
      default = {};
    };
  };

  config = lib.mkIf (cfg != {}) {
    users = {
      # Create users & groups if needed.
      users = lib.listToAttrs (map ({
          serviceName,
          uid,
          groups,
          ...
        }: {
          name = serviceName;
          value = {
            inherit uid;

            group = serviceName;

            isSystemUser = true;

            extraGroups = groups;
          };
        })
        usersToCreate);

      groups = lib.listToAttrs (map ({
          serviceName,
          gid,
          ...
        }: {
          name = serviceName;
          value = {
            inherit gid;
          };
        })
        usersToCreate);
    };

    services.docker-compose = {
      enable = true;

      networks = lib.listToAttrs (map (network: {
          name = network;
          value = {
          };
        })
        networks);

      projects =
        lib.mapAttrs (projectName: projectOptions: let
          # All networks needed for this project.
          projectNetworks = lib.unique (lib.flatten (lib.mapAttrsToList (serviceName: {networks, ...}: networks) projectOptions.services));
        in {
          compose = {
            services = lib.mapAttrs (serviceName: {
              image,
              environment,
              networks,
              volumes,
              ports,
              forwardLocalTime,
              forwardHostname,
              memoryLimit,
              user,
              extraConfig,
            }:
              lib.mkMerge [
                {
                  inherit image networks ports;

                  container_name = serviceName;

                  user = lib.mkIf user.runContainerAsUser "${toString user.uid}:${toString user.gid}";

                  logging = {
                    driver = "json-file";

                    options = {
                      max-size = "1m";
                      max-file = "1";
                    };
                  };

                  deploy = {
                    resources = {
                      limits = {
                        memory = memoryLimit;
                      };
                    };
                  };

                  environment = lib.mkMerge [
                    environment
                    (lib.optionalAttrs user.passEnvironment {
                      UID = toString user.uid;
                      GID = toString user.gid;
                    })
                  ];

                  hostname = lib.mkIf forwardHostname config.networking.hostName;

                  volumes = volumes ++ lib.optional forwardLocalTime "/etc/localtime:/etc/localtime:ro";
                }
                extraConfig
              ])
            projectOptions.services;

            # Specify networks in docker compose file
            networks = lib.listToAttrs (map (network: {
                name = network;
                value = {
                  external = true;
                  name = network;
                };
              })
              projectNetworks);
          };

          networks = projectNetworks;
        })
        cfg;
    };
  };
}
