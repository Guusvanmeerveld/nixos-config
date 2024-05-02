{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.kitty;
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
        foreground = "#${config.colorScheme.palette.base05}";
        background = "#${config.colorScheme.palette.base00}";

        # background_opacity = "0.9";

        selection_foreground = "#${config.colorScheme.palette.base06}";
        selection_background = "#${config.colorScheme.palette.base0D}";

        color0 = "#${config.colorScheme.palette.base01}";
        color1 = "#${config.colorScheme.palette.base08}";
        color2 = "#${config.colorScheme.palette.base0B}";
        color3 = "#${config.colorScheme.palette.base0A}";
        color4 = "#${config.colorScheme.palette.base0D}";
        color5 = "#${config.colorScheme.palette.base0E}";
        color6 = "#${config.colorScheme.palette.base0C}";
        color7 = "#${config.colorScheme.palette.base07}";
      };

      font = {
        size = 14;
        name = "Fira Code";
      };
    };
  };
}
