{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.grim;

  app-name = "grimshot";

  application = pkgs.writeShellApplication {
    name = app-name;

    runtimeInputs = with pkgs; [grim slurp wl-clipboard];

    text = ''
      grim -g "$(slurp -d)" - | wl-copy -t image/png
    '';
  };
in {
  options = {
    custom.programs.grim = {
      enable = lib.mkEnableOption "Enable Grim wayland image grabber";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.defaultApplications.screenshot = {
      name = "grim";
      path = "${application}/bin/${app-name}";
      wm-class = "grim";
    };

    home.packages = [application];
  };
}
