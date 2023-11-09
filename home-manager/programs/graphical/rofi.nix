{ config, pkgs, colors, font, ... }:
{
  programs.rofi =
    {
      enable = true;

      font = "${font.primary} 14";

      terminal = "${pkgs.kitty}/bin/kitty";

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

            background-color = mkLiteral colors.background.primary;
            text-color = mkLiteral colors.text.primary;
          };

          "window" = {
            transparency = "real";
          };

          "mainbox" = {
            children = map mkLiteral [ "inputbar" "listview" ];
          };

          "inputbar" = {
            background-color = mkLiteral colors.background.alt.primary;
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
          };

          "element-text" = {
            padding = mkLiteral "10px 0";
            text-color = mkLiteral colors.text.secondary;
          };

          "element-text selected" = {
            text-color = mkLiteral colors.text.primary;
          };

        };

      plugins = with pkgs; [
        rofi-calc
      ];
    };
}

