{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.custom;
in {
  options = {
    custom.user = lib.mkOption {
      type = lib.types.str;
      default = "guus";
    };
  };

  config = {
    users.users = {
      "${cfg.user}" = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel" "video" "docker"];
      };
    };
  };
}
