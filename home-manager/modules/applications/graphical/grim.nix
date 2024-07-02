{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.grim;

  app-name = "grimshot";

  application = pkgs.writeShellApplication {
    name = app-name;

    runtimeInputs = with pkgs; [grim slurp sway jq wl-clipboard];

    text = ''
      grim -g "$(slurp -d)" -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" - | wl-copy -t image/png
    '';
  };
in {
  options = {
    custom.applications.graphical.grim = {
      enable = lib.mkEnableOption "Enable Grim wayland image grabber";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.defaultApplications.screenshot = {
      name = "grim";
      path = "${application}/bin/${app-name}";
      wm-class = "grim";
    };

    home.packages = [application];
  };
}
