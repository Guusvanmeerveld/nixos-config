{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.wayland-screenshot;

  screenshotPackage = pkgs.writeShellApplication {
    name = "wayland-screenshot";

    runtimeInputs = with pkgs; [grim slurp satty];

    text = ''
      grim -g "$(slurp -d)" -t ppm - | satty --filename - --output-filename ~/Pictures/Screenshots/satty-"$(date '+%Y%m%d-%H:%M:%S')".png
    '';
  };

  ocrPackage = pkgs.writeShellApplication {
    name = "wayland-ocr";

    runtimeInputs = with pkgs; [grim slurp tesseract wl-clipboard-rs];

    text = ''
      grim -g "$(slurp -d)" -t ppm - | tesseract - - -l eng+nld | wl-copy
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
        package = screenshotPackage;
        keybind = "Print";
      }

      {
        package = ocrPackage;
        keybind = "Shift+Print";
      }
    ];

    home.packages = [screenshotPackage];
  };
}
