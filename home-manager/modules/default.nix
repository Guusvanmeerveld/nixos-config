{
  config,
  lib,
  ...
}: {
  imports = [./wm ./applications];

  options = {
    custom.nixConfigLocation = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nix/config";
    };
  };
}
