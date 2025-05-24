{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.kitty;

  package = pkgs.kitty;
  execPath = lib.getExe package;
in {
  options = {
    custom.programs.kitty = {
      enable = lib.mkEnableOption "Enable Kitty terminal emulator";

      font = lib.mkOption {
        type = lib.types.str;
        default = config.custom.programs.theming.font.monospace.name;
        description = "The font to use for kitty";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.defaultApplications.terminal = {
      name = "kitty";
      path = execPath;
      wm-class = "kitty";
    };

    home.sessionVariables = {
      TERMINAL = execPath;
    };

    programs.zsh.initContent = ''
      if [[ $TERM == "xterm-kitty" ]]; then
        alias ssh='kitten ssh'
      fi
    '';

    programs.kitty = {
      inherit package;

      enable = true;

      settings = {
        foreground = "#${config.colorScheme.palette.base06}";
        background = "#${config.colorScheme.palette.base00}";

        background_opacity = "0.95";

        selection_foreground = "#${config.colorScheme.palette.base07}";
        selection_background = "#${config.colorScheme.palette.base0D}";

        color0 = "#${config.colorScheme.palette.base01}";
        color1 = "#${config.colorScheme.palette.base08}";
        color2 = "#${config.colorScheme.palette.base0B}";
        color3 = "#${config.colorScheme.palette.base0A}";
        color4 = "#${config.colorScheme.palette.base0D}";
        color5 = "#${config.colorScheme.palette.base0E}";
        color6 = "#${config.colorScheme.palette.base0C}";
        color7 = "#${config.colorScheme.palette.base07}";

        window_padding_width = 10;
      };

      font = {
        size = 14;
        name = cfg.font;
      };
    };
  };
}
