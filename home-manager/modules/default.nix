{
  config,
  lib,
  ...
}: {
  imports = [./wm ./applications ./colors.nix];

  options = {
    custom.nixConfigLocation = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nix/config";
    };
  };

  config = {
    news.display = "silent";
  };
}
