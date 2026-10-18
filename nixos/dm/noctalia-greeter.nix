{
  lib,
  config,
  ...
}: let
  cfg = config.custom.dm.noctalia-greeter;
  defaultCursorOptions = config.custom.shared.theming.cursor;
in {
  options = {
    custom.dm.noctalia-greeter = {
      enable = lib.mkEnableOption "Enable noctalia greeter via greetd";

      wallpaper = lib.mkOption {
        type = lib.types.str;
        description = "Wallpaper settings";
      };

      output = lib.mkOption {
        type = with lib.types; attrsOf (oneOf [str int float]);
        description = "Display settings for the greeter";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.noctalia-greeter = {
      enable = true;

      settings = {
        inherit (cfg) output;

        cursor.size = 24;
        keyboard.layout = "us";

        appearance = {
          wallpaper = {
            path = cfg.wallpaper;
            fill_mode = "stretch";
          };

          scheme = "Ayu";
          hide_logo = true;
        };

        clock = {
          enabled = true;
          position = "above-panel";
          time_format = "{:%H:%M}";
          date_format = "%A, %x";
        };

        auth.allow_empty_password = true;

        idle.timeout = 300;
      };

      cursorTheme = {
        inherit (defaultCursorOptions) package name;
      };
    };
  };
}
