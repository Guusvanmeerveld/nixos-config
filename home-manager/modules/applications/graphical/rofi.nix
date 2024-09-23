{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.rofi;

  package = pkgs.rofi;
in {
  options = {
    custom.applications.graphical.rofi = {
      enable = lib.mkEnableOption "Enable Rofi start menu";

      terminal = lib.mkOption {
        type = lib.types.str;
        default = config.custom.applications.graphical.defaultApplications.terminal.path;
        description = "The default terminal to use";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.defaultApplications.menu = {
      name = "rofi";
      path = "${lib.getExe package} -show drun";
      wm-class = "Rofi";
    };

    programs.rofi = {
      inherit package;

      # Config highly inspired by https://github.com/catppuccin/rofi
      enable = true;

      font = "Fira Code 14";

      cycle = true;

      terminal = cfg.terminal;

      extraConfig = {
        modi = "drun,ssh,run,window,filebrowser";

        case-sensitive = false;
        show-icons = true;
        steal-focus = false;

        hide-scrollbar = true;

        sidebar-mode = true;

        # Matching settings
        matching = "fuzzy";
        tokenize = true;

        # SSH settings
        ssh-client = "ssh";
        ssh-command = "{terminal} -e {ssh-client} {host} [-p {port}]";

        parse-hosts = true;
        parse-known-hosts = true;

        # Drun settings
        drun-display-format = "{icon} {name}";
        drun-match-fields = "name,generic,exec,categories,keywords";
        drun-show-actions = false;
        drun-url-launcher = "xdg-open";
        drun-use-desktop-cache = false;
        # drun = {
        #   parse-user = true;
        #   parse-system = true;
        # };

        # Run settings
        run-command = "{cmd}";
        run-shell-command = "{terminal} -e {cmd}";

        # Display
        display-window = " Windows";
        display-windowcd = " Windows CD";
        display-run = " Run";
        display-ssh = " SSH";
        display-drun = "󰀻 Apps";
        display-combi = "Combi";
        display-keys = "Keys";
        display-filebrowser = "󰉋 Files";
      };

      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;

        height = 360;
        width = 600;

        bg-color = mkLiteral "#${config.colorScheme.palette.base00}";
        alt-bg-color = mkLiteral "#${config.colorScheme.palette.base01}";

        font-color = mkLiteral "#${config.colorScheme.palette.base05}";
        alt-font-color = mkLiteral "#${config.colorScheme.palette.base04}";

        primary-color = mkLiteral "#${config.colorScheme.palette.base0D}";
      in {
        # "*" = {

        # };

        "window" = {
          width = mkLiteral (toString width);
          height = mkLiteral (toString height);

          border-radius = mkLiteral "5px";

          border = mkLiteral "3px";
          border-color = alt-bg-color;

          background-color = bg-color;
        };

        "mainbox" = {
          background-color = bg-color;
        };

        "inputbar" = {
          children = [(mkLiteral "prompt") (mkLiteral "entry")];

          background-color = bg-color;
          border-radius = mkLiteral "5px";
          padding = mkLiteral "2px";
        };

        "prompt" = {
          background-color = primary-color;
          text-color = font-color;
          padding = mkLiteral "6px 10px 6px 10px";
          border-radius = mkLiteral "3px";
          margin = mkLiteral "20px 0 0 20px";
        };

        "entry" = {
          background-color = bg-color;
          text-color = font-color;
          padding = mkLiteral "6px";
          margin = mkLiteral "20px 0 0 10px";
        };

        "listview" = {
          background-color = bg-color;

          border = mkLiteral "0 0 0";
          padding = mkLiteral "6px 0 0";
          margin = mkLiteral "10px 20px 0 20px";

          columns = mkLiteral "2";
          lines = mkLiteral "5";
        };

        "element-text, element-icon, mode-switcher" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        "element" = {
          background-color = bg-color;
          text-color = font-color;

          # margin = mkLiteral "0 20px 0 0";
          padding = mkLiteral "5px";
        };

        "element-icon" = {
          size = mkLiteral "25px";
        };

        "element selected" = {
          background-color = alt-bg-color;
          text-color = alt-font-color;

          border-radius = mkLiteral "3px";
        };

        "mode-switcher" = {
          spacing = mkLiteral "0";
        };

        "button" = {
          background-color = alt-bg-color;
          text-color = alt-font-color;

          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.5";

          padding = mkLiteral "10px";
        };

        "button selected" = {
          background-color = bg-color;
          text-color = primary-color;
        };

        # "message" = {
        #   background-color
        # }
      };

      plugins = with pkgs; [
        rofi-calc
      ];
    };
  };
}
