{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.kitty; in
{
  options = {
    custom.applications.graphical.kitty = {
      enable = lib.mkEnableOption "Enable Kitty terminal emulator";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      theme = "Broadcast";

      font = {
        size = 14;
        name = config.custom.theme.font.name;
      };
    };
  };
}
