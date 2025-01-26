{
  config,
  lib,
  ...
}: {
  imports = [./wm ./applications ./colors.nix ./xdg];

  options = {
    custom.nixConfigLocation = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nix/config";
    };
  };

  config = {
    news.display = "silent";

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    # Enable home-manager and git
    # Essential for every install
    programs.home-manager.enable = true;
    programs.git.enable = true;
  };
}
