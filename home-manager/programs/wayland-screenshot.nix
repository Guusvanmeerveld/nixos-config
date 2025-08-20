{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.wayland-screenshot;

  package = pkgs.writeShellApplication {
    name = "wayland-screenshot";

    runtimeInputs = with pkgs; [grim slurp satty];

    text = ''
      grim -g "$(slurp -d)" -t ppm - | satty --filename - --output-filename ~/Pictures/Screenshots/satty-"$(date '+%Y%m%d-%H:%M:%S')".png
    '';
  };
in {
  options = {
    custom.programs.wayland-screenshot = {
      enable = lib.mkEnableOption "Enable Wayland screenshot program";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit package;
        keybind = "Print";
      }
    ];

    home.packages = [package];
  };
}
