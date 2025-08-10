{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.grim;

  application = pkgs.writeShellApplication {
    name = "grimshot";

    runtimeInputs = with pkgs; [grim slurp satty];

    text = ''
      grim -g "$(slurp -d)" -t ppm - | satty --filename - --output-filename ~/Pictures/Screenshots/satty-"$(date '+%Y%m%d-%H:%M:%S')".png
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
      path = lib.getExe application;
      wm-class = "grim";
    };

    home.packages = [application];
  };
}
