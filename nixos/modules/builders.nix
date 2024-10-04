{
  lib,
  config,
  ...
}: let
  cfg = config.custom.builders;
in {
  options = {
    custom.builders = {
      enable = lib.mkEnableOption "Enable remote build";

      machines = lib.mkOption {
        type = lib.types.listOf lib.types.submodule {
          options = {
            hostName = lib.mkOption {
              type = lib.types.str;
              description = "The hostname of the build machine.";
            };

            system = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "x86_64-linux";
              description = ''
                The system type the build machine can execute derivations on.
                Either this attribute or {var}`systems` must be
                present, where {var}`system` takes precedence if
                both are set.
              '';
            };
          };
        };

        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nix.buildMachines =
      map (machine: {
        hostName = machine.hostName;
        system = machine.system;
        protocol = "ssh";
        maxJobs = 3;
        speedFactor = 4;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      })
      cfg.machines;

    nix.distributedBuilds = true;

    # optional, useful when the builder has a faster internet connection than yours
    nix.settings = {
      builders-use-substitutes = true;
    };
  };
}
