{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.kitty;

  package = pkgs.kitty;
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
    custom.wm.applications = [
      {
        inherit package;
        keybind = "$mod+Return";
        appId = "kitty";
      }
    ];

    xdg.terminal-exec = {
      enable = true;

      settings = {
        default = [
          "kitty.desktop"
        ];
      };
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
        background_opacity = 0.90;
      };

      font = {
        size = 14;
        name = cfg.font;
      };
    };
  };
}
