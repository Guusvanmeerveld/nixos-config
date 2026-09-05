{
  config,
  lib,
  ...
}: {
  imports = [./wm ./xdg ./programs ./services ./colors.nix];

  options = {
    custom.nixConfigLocation = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Code/nixos-config";
    };
  };

  config = {
    news.display = "silent";

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    # Essential for every install
    programs.git.enable = true;
  };
}
