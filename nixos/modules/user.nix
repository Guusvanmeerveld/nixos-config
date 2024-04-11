{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.custom;
in {
  options = {
    custom.user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "guus";
      };

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
        default = [];
      };
    };
  };

  config = {
    users.users = {
      "${cfg.user.name}" = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel" "video" "docker"];

        openssh.authorizedKeys.keys = cfg.user.authorizedKeys;
      };
    };
  };
}
