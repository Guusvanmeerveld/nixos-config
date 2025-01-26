{
  config,
  lib,
  inputs,
  outputs,
  shared,
  ...
}: let
  cfg = config.custom.users;
  globalGroups = config.custom.usersGlobalGroups;

  usersWithHomeManager = lib.filterAttrs (_: config: config.homeManager.enable) cfg;
in {
  imports = [inputs.home-manager.nixosModules.default];

  options = {
    custom = {
      usersGlobalGroups = lib.mkOption {
        type = with lib.types; listOf str;
        description = "A list of groups that every user on this machine should be part of";
        default = [];
      };

      users = lib.mkOption {
        type = with lib.types;
          attrsOf (submodule {
            options = {
              isSuperUser = lib.mkEnableOption "Whether this user is a super user";

              groups = lib.mkOption {
                type = listOf str;
                description = "A list of groups that this user should be in";
                default = [];
              };

              homeManager = {
                enable = lib.mkEnableOption "Enable home-manager configuration for this user";

                config = lib.mkOption {
                  type = path;
                  description = "Path to the home-manager config file";
                };
              };

              ssh = {
                keys = lib.mkOption {
                  type = listOf str;
                  description = "A list of public keys that are authorized to connect";
                  default = [];
                };
              };
            };
          });
      };
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {inherit inputs outputs shared;};

      users = lib.mapAttrs (username: config: {imports = [config.homeManager.config];}) usersWithHomeManager;
    };

    users.users =
      lib.mapAttrs (username: config: {
        isNormalUser = true;
        extraGroups = ["networkmanager" "video" "audio" "storage" "disk"] ++ (lib.optional config.isSuperUser "wheel") ++ config.groups ++ globalGroups;

        openssh.authorizedKeys.keys = config.ssh.keys;
      })
      cfg;

    nix.settings.trusted-users = ["root"] ++ lib.mapAttrsToList (username: _: username) cfg;
  };
}
