{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.launchers.rofi;

  package =
    if cfg.wayland
    then
      pkgs.rofi-wayland.override {
        plugins = with pkgs; [
          rofi-calc
          rofi-emoji-wayland
          rofi-rbw-wayland
          rofi-games
        ];
      }
    else pkgs.rofi;

  default = "drun";
in {
  options = {
    custom.wm.launchers.rofi = {
      enable = lib.mkEnableOption "Enable Rofi start menu";

      wayland = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.enable;
        description = "Whether to use the wayland version of rofi";
      };

      font = lib.mkOption {
        type = lib.types.str;
        default = config.custom.programs.theming.font.serif.name;
        description = "The font to use for rofi";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        executable = ''${lib.getExe package} -show ${default}'';
        appId = "rofi";
        keybind = "$mod+space";
      }
    ];

    programs.rofi = {
      inherit package;

      modes = [
        "drun"
        "window"
        "calc"
        "games"
        "emoji"
        "run"
        "ssh"
        # {
        #   name = "rbw";
        #   path = let
        #     package =
        #       if cfg.wayland
        #       then pkgs.rofi-rbw-wayland
        #       else pkgs.rofi-rbw-x11;
        #   in
        #     lib.getExe package;
        # }
      ];

      # Config highly inspired by https://github.com/catppuccin/rofi
      enable = true;

      font = "${cfg.font} 12";

      cycle = true;

      extraConfig = {
        case-sensitive = false;
        show-icons = true;
        steal-focus = false;

        hide-scrollbar = true;

        sidebar-mode = true;

        # Matching settings
        matching = "glob";
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

      theme = ./themes/macos-launchpad.rasi;
    };
  };
}
