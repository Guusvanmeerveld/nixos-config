{ lib, config, pkgs, ... }:
let
  theme = config.custom.theme;
  cfg = config.custom.applications.graphical.rofi;
in
{
  options = {
    custom.applications.graphical.rofi = {
      enable = lib.mkEnableOption "Enable Rofi start menu";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      font = "${theme.font.name} 14";

      cycle = true;

      extraConfig = {
        modi = "window,run,drun,filebrowser";

        case-sensitive = false;

        show-icons = true;

        run-command = "{cmd}";
        run-shell-command = "{terminal} -e {cmd}";

        display-window = "Windows";
        display-windowcd = "Window CD";
        display-run = "Run";
        display-ssh = "SSH";
        display-drun = "Apps";
        display-combi = "Combi";
        display-keys = "Keys";
        display-filebrowser = "Files";
      };

      theme =
        let inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            border = 0;
            margin = 0;
            padding = 0;
            spacing = 0;

            background-color = mkLiteral theme.background.primary;
            text-color = mkLiteral theme.text.primary;
          };

          "window" = {
            transparency = "real";
          };

          "mainbox" = {
            children = map mkLiteral [ "inputbar" "listview" ];
          };

          "inputbar" = {
            background-color = mkLiteral theme.background.alt.primary;
            children = map mkLiteral [ "prompt" "entry" ];
          };

          "entry" = {
            background-color = "inherit";
            padding = mkLiteral "12px 3px";
          };

          "prompt" = {
            background-color = "inherit";
            padding = mkLiteral "12px";
          };

          "listview" = {
            lines = 8;
          };

          "element" = {
            children = map mkLiteral [ "element-icon" "element-text" ];
          };

          "element-icon" = {
            padding = mkLiteral "10px 10px";
            size = mkLiteral "3ch";
          };

          "element-text" = {
            padding = mkLiteral "10px 0";
            text-color = mkLiteral theme.text.secondary;
          };

          "element-text selected" = {
            text-color = mkLiteral theme.text.primary;
          };

        };

      plugins = with pkgs; [
        rofi-calc
      ];
    };
  };
}

