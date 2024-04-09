{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.kitty;
  theme = config.custom.wm.theme;
in {
  options = {
    custom.applications.graphical.kitty = {
      enable = lib.mkEnableOption "Enable Kitty terminal emulator";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      shellIntegration = {
        enableZshIntegration = config.custom.applications.shell.zsh.enable;
      };

      settings = {
        foreground = theme.text.primary;
        background = theme.background.primary;

        background_opacity = "0.9";

        selection_foreground = theme.text.primary;
        selection_background = theme.primary;
      };

      font = {
        size = 14;
        name = config.custom.wm.theme.font.name;
      };
    };
  };
}
